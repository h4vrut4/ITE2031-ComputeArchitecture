#include <iomanip>
#include <iostream>
#include "CPU.h"
#include "globals.h"

#define VERBOSE 0

using namespace std;

CPU::CPU() {}

// Reset stateful modules
void CPU::init(string inst_file) {
	// Initialize the register file
	rf.init(false);
	// Load the instructions from the memory
	mem.load(inst_file);
	// Reset the program counter
	PC = 0;

	// Set the debugging status
	status = CONTINUE;
}

// This is a cycle-accurate simulation
uint32_t CPU::tick() {
    // Pipeline latches
    static IF_ID_Latch if_id;
    static ID_EX_Latch id_ex;
    static EX_MEM_Latch ex_mem;
    static MEM_WB_Latch mem_wb;
	static uint32_t PC; //항상 Predict not-taken으로 해서 계속 값 가져오기
	static uint32_t stall = 0; // Stall cycle 수를 관리
	static uint32_t delay_cycles = 0; // 종료 직전 대기 사이클 수 관리

	uint32_t instruction;
	CTRL::ParsedInst parsed_inst;
	CTRL::Controls controls;
	uint32_t rs_data, rt_data, ext_imm;
	uint32_t operand1, operand2, alu_result;
	uint32_t mem_data;
	uint32_t wr_data;
	//위 변수들을 인자로 이용하여 연산 결과를 받아두고,
	//tick함수 마지막 부분에서 latch를 업데이트

	mem.imemAccess(PC, &instruction, &delay_cycles);
	// printf("PC: %08X, Instruction: %08X\n", PC, instruction);
	//IF_ID Latch

	ctrl.splitInst(if_id.instruction, &parsed_inst);
	ctrl.controlSignal(parsed_inst.opcode, parsed_inst.funct, &controls);
	ctrl.signExtend(parsed_inst.immi, controls.SignExtend, &ext_imm);
	if(!stall) //stall이 0인 경우에만 실행! (즉 정상 작동 중일때에만)
		stall = detectHazard(parsed_inst.opcode, parsed_inst.funct, parsed_inst.rs, parsed_inst.rt,
		id_ex.rd, id_ex.rt, id_ex.controls.RegWrite,
		ex_mem.wr_addr, ex_mem.controls.RegWrite,
		mem_wb.wr_addr, mem_wb.controls.RegWrite);
	rf.read(parsed_inst.rs, parsed_inst.rt, &rs_data, &rt_data);

	//ID_EX Latch

	operand1 = id_ex.rs_data;
	operand2 = (id_ex.controls.ALUSrc) ? id_ex.ext_imm : id_ex.rt_data;
	alu.compute(operand1, operand2, id_ex.shamt, id_ex.controls.ALUOp, &alu_result);

	//EX_MEM Latch

	mem.dmemAccess(ex_mem.alu_result, &mem_data, ex_mem.rt_data, ex_mem.controls.MemRead, ex_mem.controls.MemWrite);

	//MEM_WB Latch

	wr_data = mem_wb.controls.MemtoReg ? mem_wb.mem_data : mem_wb.alu_result;
	if(mem_wb.controls.SavePC){ //JAL일 경우
		mem_wb.wr_addr = 31;
		wr_data = mem_wb.PC;
	}
	rf.write(mem_wb.wr_addr, wr_data, mem_wb.controls.RegWrite);
	// printf("MEM_WB: PC %08x, wr_addr %d, wr_data %08x\n", mem_wb.PC, mem_wb.wr_addr, wr_data);

///////////////////////////////////////////////////////////////////////////////

	//mem_wb 업데이트
	mem_wb.mem_data = mem_data;
	mem_wb.controls = ex_mem.controls;
	mem_wb.alu_result = ex_mem.alu_result;
	mem_wb.wr_addr = ex_mem.wr_addr;
	mem_wb.PC = ex_mem.PC; //JAL의 경우 r31에 PC를 저장해야해서 필요.

	//ex_mem 업데이트
	ex_mem.alu_result = alu_result;
	ex_mem.wr_addr = (id_ex.controls.RegDst) ? id_ex.rd : id_ex.rt;
	ex_mem.controls = id_ex.controls;
	// ex_mem.rs_data = id_ex.rs_data; //JR연산을 위해
	ex_mem.rt_data = id_ex.rt_data;
	// ex_mem.immj = id_ex.immj; //jump연산을 위해 남겨둠
	ex_mem.PC = id_ex.PC;


	//id_ex, if_id 업데이트 w.flush, Stall 처리
	if (stall > 0) {
	    // Stall: IF/ID 및 ID/EX latch 유지, PC 업데이트 중지
	    id_ex = {}; // ID/EX latch flush

	    if_id.instruction = if_id.instruction; // 유지
	    PC = PC;                               // PC 업데이트 중지
	    stall--;                               // Stall cycle 감소
	} else {
	    // 정상적으로 진행
		//id_ex 업데이트
		id_ex.controls = controls;
		id_ex.ext_imm = ext_imm;
		id_ex.rs_data = rs_data;
		id_ex.rt_data = rt_data;
		id_ex.shamt = parsed_inst.shamt;
		id_ex.rt = parsed_inst.rt; 
		id_ex.rd = parsed_inst.rd; 
		id_ex.immj = parsed_inst.immj; //jump연산을 위해 남겨둠
		id_ex.PC = if_id.PC;

		// stall 처리를 위해서 PC + 4를 if문 내부로 이동했음.
	    if_id.instruction = instruction;
		PC = PC + 4; //Predict not-taken
	    if_id.PC = PC;
	}

///////////////////////////////////////////////////////////////////////////////
	
	//ID단계 진행 이후 Jump, Branch를 통해 PC 업데이트 해야함.
	//Branch resolution은 ID stage에서 하는 것으로 구현했다. (즉 그냥 alu 연산기가 하나 더 있다고 가정)
	//현재 PC update를 하는 시점은, ID/EX latch가 업데이트 된 이후이다.
	if(id_ex.controls.JR)
		PC = id_ex.rs_data;
	else if (id_ex.controls.Branch && id_ex.controls.ALUOp == ALU_EQ && id_ex.rs_data == id_ex.rt_data)
    	PC = id_ex.PC + (id_ex.ext_imm << 2); // BEQ 처리
	else if (id_ex.controls.Branch && id_ex.controls.ALUOp == ALU_NEQ && id_ex.rs_data != id_ex.rt_data)
    	PC = id_ex.PC + (id_ex.ext_imm << 2); // BNE 처리
	else if(id_ex.controls.Jump)
		PC = (id_ex.PC & 0xF0000000) | (id_ex.immj << 2); //상위 4비트와 immj<<2 28비트 사용
	//모든 조건문이 거짓이면 어차피 계속 not-taken으로 가정하고 있어서 PC+4 들어감.

	// Flush pipeline (IF/ID latch만 비움), 
	// PC는 위에서 새로운 값으로 업데이트 되었으니, 다음 fetch에서 새로운 instruction을 가져올 것
	if (id_ex.controls.JR || id_ex.controls.Jump || 
	    (id_ex.controls.Branch && id_ex.controls.ALUOp == ALU_EQ && id_ex.rs_data == id_ex.rt_data) ||
		(id_ex.controls.Branch && id_ex.controls.ALUOp == ALU_NEQ && id_ex.rs_data != id_ex.rt_data)) {
	    if_id.instruction = 0; // Flush IF/ID latch
	    if_id.PC = 0;          // PC 정보도 초기화
	}


	return 1;
}


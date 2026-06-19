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
	ForwardingSignals fw; //FORWARDING 신호 받기.

    // Pipeline latches
    static IF_ID_Latch if_id;
    static ID_EX_Latch id_ex;
    static EX_MEM_Latch ex_mem;
    static MEM_WB_Latch mem_wb;
	static uint32_t stall = 0; // Stall cycle 수를 관리
	static uint32_t delay_cycles = 0; // 종료 직전 대기 사이클 수 관리

	uint32_t instruction;
	CTRL::ParsedInst parsed_inst;
	CTRL::Controls controls;
	uint32_t rs_data, rt_data, ext_imm;
	uint32_t operand1 = 0, operand2 = 0; 
	uint32_t alu_result;
	uint32_t mem_data;
	uint32_t wr_data;

	//위 변수들을 인자로 이용하여 연산 결과를 받아두고,
	//tick함수 마지막 부분에서 latch를 업데이트

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//forwarding을 위해 순서 조정. WB단계만 맨 앞으로 가져옴.
	//latch초기화는 마지막에 이루어지기 때문에 상관 없음.
	wr_data = mem_wb.controls.MemtoReg ? mem_wb.mem_data : mem_wb.alu_result;
	if(mem_wb.controls.SavePC){ //JAL일 경우
		mem_wb.wr_addr = 31;
		wr_data = mem_wb.PC + 4;
	}
	rf.write(mem_wb.wr_addr, wr_data, mem_wb.controls.RegWrite);
	uint32_t nextPC;
	bool predicted_taken = predictor.predict(PC, nextPC); // 이전에 잘 예측 되어서 들어온 PC를 사용한다고 생각하자.

	mem.imemAccess(PC, &instruction, &delay_cycles); 



	ctrl.splitInst(if_id.instruction, &parsed_inst);
	ctrl.controlSignal(parsed_inst.opcode, parsed_inst.funct, &controls);
	ctrl.signExtend(parsed_inst.immi, controls.SignExtend, &ext_imm);
	if (!stall)
   		stall = detectHazard(parsed_inst.opcode, parsed_inst.funct, parsed_inst.rs, parsed_inst.rt,
                         id_ex.rt, id_ex.controls.MemRead); // RegWrite → MemRead로 바뀜
	rf.read(parsed_inst.rs, parsed_inst.rt, &rs_data, &rt_data);
	
	if (mem_wb.controls.RegWrite && mem_wb.wr_addr != 0) { 	// Internal Forwarding: WB에서 쓰려는 값이랑 겹치면 override
	    if (mem_wb.wr_addr == parsed_inst.rs) {
	        rs_data = wr_data;
	    }
	    if (mem_wb.wr_addr == parsed_inst.rt) {
	        rt_data = wr_data;
	    }
	}
	


	computeForwarding(id_ex.rs, id_ex.rt,
	                  ex_mem.wr_addr, ex_mem.controls.RegWrite,
	                  mem_wb.wr_addr, mem_wb.controls.RegWrite,
	                  &fw);
	switch (fw.ForwardA) {
	    case 0: operand1 = id_ex.rs_data; break;
	    case 1: operand1 = wr_data; break;
	    case 2: operand1 = ex_mem.alu_result; break;
	}
	if (id_ex.controls.ALUSrc)
	    operand2 = id_ex.ext_imm;
	else {
	    switch (fw.ForwardB) {
	        case 0: operand2 = id_ex.rt_data; break;
	        case 1: operand2 = wr_data; break;
	        case 2: operand2 = ex_mem.alu_result; break;
	    }
	}
	alu.compute(operand1, operand2, id_ex.shamt, id_ex.controls.ALUOp, &alu_result);



	mem.dmemAccess(ex_mem.alu_result, &mem_data, ex_mem.rt_data, ex_mem.controls.MemRead, ex_mem.controls.MemWrite);



	// //[DEBUGGING CODE]
	// if(mem_wb.controls.SavePC) //JAL일 경우
	// 	printf("$ra: %08X, PC of the Instruction: %08X\n", wr_data, mem_wb.PC);
	// if (mem_wb.controls.RegWrite)
    // 	printf("[DEBUG] Writing back: R[%d] = 0x%08X\n", mem_wb.wr_addr, wr_data); //[DEBUG]
	// printf("[DEBUG] rs_data (i.e., base register $%d) = 0x%08X\n", parsed_inst.rs, rs_data); //[DEBUG]
	// if (id_ex.controls.MemWrite)//[DEBUG]
	//     printf("[DEBUG] EX sw base(R[%d]) = %08X, offset = %08X, address = %08X, data = %08X, fw.ForwardB: %d\n",
	//         id_ex.rs, id_ex.rs_data, id_ex.ext_imm, alu_result, id_ex.rt_data, fw.ForwardB);
	// if (ex_mem.controls.MemRead) //[DEBUG]
	//     printf("[DEBUG] MEM Loaded mem_data = 0x%08X from address 0x%08X\n", mem_data, ex_mem.alu_result);
	// if (ex_mem.controls.MemWrite) { //[DEBUG]
	//     printf("[DEBUG] MEM Store: mem[%08X] <- %08X (from R[%d])\n", 
	//         ex_mem.alu_result, ex_mem.rt_data, id_ex.rt);
	// }
	// // printf("MEM_WB: PC %08x, wr_addr %d, wr_data %08x\n", mem_wb.PC, mem_wb.wr_addr, wr_data);
	// printf("PC: %08X, Instruction: %08X\n", PC, instruction);
	// printf("IF_ID PC: %08X\n", if_id.PC);
	// printf("ID_EX PC: %08X\n", id_ex.PC);
	// printf("EX_MEM PC: %08X\n", ex_mem.PC);
	// printf("MEM_WB PC: %08X\n", mem_wb.PC);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//branch 계산을 위해 FORWARDING 된 값 가져오기
	// Forwarding 적용된 비교용 값 준비
	uint32_t branch_rs = rs_data, branch_rt = rt_data;
	// branch resolution을 위해 사실검증 시작.
	bool actually_taken = true;
	uint32_t actual_target = 0;

	// Forward from MEM/WB
	if (mem_wb.controls.RegWrite && mem_wb.wr_addr != 0) {
	    if (mem_wb.wr_addr == parsed_inst.rs) branch_rs = wr_data;
	    if (mem_wb.wr_addr == parsed_inst.rt) branch_rt = wr_data;
	}
	
	// Forward from EX/MEM
	if (ex_mem.controls.RegWrite && ex_mem.wr_addr != 0) {
	    if (ex_mem.wr_addr == parsed_inst.rs) branch_rs = ex_mem.alu_result;
	    if (ex_mem.wr_addr == parsed_inst.rt) branch_rt = ex_mem.alu_result;
	}
	
	// Forward from ID/EX (최신 연산 결과가 바로 뒤 cycle일 때도 고려)
	uint32_t id_ex_wr_addr = (id_ex.controls.RegDst) ? id_ex.rd : id_ex.rt;
	if (id_ex.controls.RegWrite && id_ex_wr_addr != 0) {
	    if (id_ex_wr_addr == parsed_inst.rs) branch_rs = alu_result; // 필요 시 ALU result 저장해야 함
	    if (id_ex_wr_addr == parsed_inst.rt) branch_rt = alu_result;
	}
	
	//ID단계 진행 이후 Jump, Branch를 통해 PC 업데이트 해야함.
	//Branch resolution은 ID stage에서 하는 것으로 구현했다. (즉 그냥 alu 연산기가 하나 더 있다고 가정)
		//여기서 이번에 fetch할 PC로 계산한 nextPC를 잘 예측했는지 확인하면 되는거잖아.아닌가?
		// ㅈㅁ..ID단계에 있는 애로 검증을한다 = IF단계에는 뭔가 다른애가 이미 들어와있다 = PC를 검증해야한다? 이게 꼭 같은 사이클에 비교될 필요는 없는건가
		//그럼 이 taken정보도 latch로 한번 넘겨줘야하나?
		//정확하게는 이 IF(nextPC에 들어왔을거아님./ 얘가 PC에 있을 때->) ID(지금 여기 있는 애의 명령어로 예측한 IF를 검증해야하는건데)
		//그럼 한사이클 넘겨줘야할거같은데? actual_target, 
	if(controls.JR){ 
		PC = rs_data; //얘는 여기서 계산해줘야함.
		// actual_target = rs_data;
	} else if (controls.Branch && controls.ALUOp == ALU_EQ && branch_rs == branch_rt){
    	// PC = if_id.PC + 4 + (ext_imm << 2); // BEQ 처리
		actual_target = if_id.PC + 4 + (ext_imm << 2);
	} else if (controls.Branch && controls.ALUOp == ALU_NEQ && branch_rs != branch_rt){
    	// PC = if_id.PC + 4 + (ext_imm << 2); // BNE 처리
		actual_target= if_id.PC + 4 + (ext_imm << 2);
	} else if(controls.Jump){
		// PC = (if_id.PC & 0xF0000000) | (parsed_inst.immj << 2); //상위 4비트와 immj<<2 28비트 사용
		actual_target = (if_id.PC & 0xF0000000) | (parsed_inst.immj << 2);
	} else {
		actual_target = PC + 4;
		actually_taken = false;
	}

	//branch resolution
	bool mispredict = false;
	if(instruction != 0 && !controls.JR){
		if (if_id.predicted_taken != actually_taken){ // PHT가 잘 동작했는지. T/NT
		    mispredict = true;
		} else if (if_id.predicted_taken && if_id.PC != actual_target) { // T이라면, BTB가 잘 동작했는지. (= 이전에 fetch.. 잘 한거 맞나요? 를 체크하는거임.)
		    mispredict = true;
		} 
	}

	bool is_Branch = controls.Branch; //근데 일단 이러면, jump가 꼭 아니어도, 그니까 다른 명령어여도 될 수 있는거 아닌가?
	if(controls.Branch) is_Branch = controls.Branch;
	else if(controls.Jump) is_Branch = 0;

	if(!controls.JR && (controls.Branch || controls.Jump)) //JR은 고려 안하기. 이렇게 하면 항상 JR연산은 false뜨겠지!
		predictor.update(if_id.PC, actually_taken, actual_target, is_Branch);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//놀라운사실! MEM에 접근할 녀석도 Forwarding을 받는답니다!!
	uint32_t forwarded_rt_data = id_ex.rt_data;
	switch (fw.ForwardB) {
	    case 0: forwarded_rt_data = id_ex.rt_data; break;
	    case 1: forwarded_rt_data = wr_data; break;
	    case 2: forwarded_rt_data = ex_mem.alu_result; break;
	}

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
	ex_mem.rt_data = forwarded_rt_data; // forwarding된 rt_data를 따로 계산
	ex_mem.PC = id_ex.PC;


	//id_ex, if_id 업데이트 w.flush, Stall 처리
	if (mispredict) {
		id_ex.controls = controls;
		id_ex.ext_imm = ext_imm;
		id_ex.rs_data = rs_data;
		id_ex.rt_data = rt_data; 
		id_ex.shamt = parsed_inst.shamt;
		id_ex.rs = parsed_inst.rs;
		id_ex.rt = parsed_inst.rt; //FORWARDING을 위해 추가.
		id_ex.rd = parsed_inst.rd; 
		id_ex.immj = parsed_inst.immj; //jump연산을 위해 남겨둠
		id_ex.PC = if_id.PC;
	    if_id = {};
		if_id.PC = 0;
	    PC = actual_target; // 올바른 PC로 되돌림
	} else {
		if (stall > 0){//|| controls.JR){ // 사실 JR일 땐 flush 굳이 안해도 될 것 같긴 한데 그냥흘러가서??
			id_ex = {}; //stall이 걸렸는데 mispredict가 안나고, savePC를 하는 상황인게 있나? 그러면 예외처리해야하는데
			id_ex.PC = 0;
		} else {
		    // 정상적으로 진행
			//id_ex 업데이트
			id_ex.controls = controls;
			id_ex.ext_imm = ext_imm;
			id_ex.rs_data = rs_data;
			id_ex.rt_data = rt_data; 
			id_ex.shamt = parsed_inst.shamt;
			id_ex.rs = parsed_inst.rs;
			id_ex.rt = parsed_inst.rt; //FORWARDING을 위해 추가.
			id_ex.rd = parsed_inst.rd; 
			id_ex.immj = parsed_inst.immj; //jump연산을 위해 남겨둠
			id_ex.PC = if_id.PC;
		}

		if (stall > 0) {
		    // Stall: IF/ID 및 ID/EX latch 유지, PC 업데이트 중지
		    if_id.instruction = if_id.instruction; // 유지
		    PC = PC;                               // PC 업데이트 중지
			stall--;
		} else if (controls.JR){
			if_id.instruction = 0; // 맞나?
			if_id.PC = 0;          // PC 정보도 초기화
			//얘 PC는 branch resolution 단계에서 따로 처리되고.
		} else {
		    if_id.instruction = instruction;
			if_id.PC = PC;
			if_id.predicted_taken = predicted_taken;
			PC = nextPC;
		}
	}
	return 1;
}


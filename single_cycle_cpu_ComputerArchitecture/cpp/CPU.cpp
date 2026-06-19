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
	// These are just one of the implementations ...

	// wire for instruction
	uint32_t inst;

	// parsed & control signals (wire)
	CTRL::ParsedInst parsed_inst;
	CTRL::Controls controls;
	uint32_t ext_imm;

	// Default wires and control signals
	uint32_t rs_data, rt_data;
	uint32_t wr_addr; //for register
	uint32_t wr_data; //for register
	uint32_t operand1;
	uint32_t operand2;
	uint32_t alu_result;

	// PC_next
	uint32_t PC_next;

	// You can declare your own wires (if you want ...)
	uint32_t mem_data; //메모리에서 읽어오는 용도

	// Access the instruction memory
	mem.imemAccess(PC, &inst);
	if (status != CONTINUE) return 0;
	
	// Split the instruction & set the control signals
	ctrl.splitInst(inst, &parsed_inst);
	ctrl.controlSignal(parsed_inst.opcode, parsed_inst.funct, &controls);
	ctrl.signExtend(parsed_inst.immi, controls.SignExtend, &ext_imm);
	if (status != CONTINUE) return 0;
	
	rf.read(parsed_inst.rs, parsed_inst.rt, &rs_data, &rt_data);
	operand1 = rs_data;
	operand2 = (controls.ALUSrc) ? ext_imm : rt_data;

	alu.compute(operand1, operand2, parsed_inst.shamt, controls.ALUOp, &alu_result);
	if (status != CONTINUE) return 0;

	// MEM (+PC Update)
	//메모리에 접근하는 경우 alu_result에 offset과 함께 계산된 결과가 들어가, addr로 사용됨
	mem.dmemAccess(alu_result, &mem_data, rt_data, controls.MemRead, controls.MemWrite);
	if (status != CONTINUE) return 0;

	// Update the PC
	if(controls.JR) PC_next = rs_data;
	else if(controls.Branch && alu_result) PC_next = PC + 4 + (ext_imm << 2);
	else if(controls.Jump){ //J, JAL은 immj를 사용함.
		if(controls.SavePC) rf.write(31, PC + 4, 1); //JAL은 r31 = pc + 4 수행해야함.
		PC_next = (PC & 0xF0000000) | (parsed_inst.immj << 2); //상위 4비트와 immj<<2 28비트 사용
	}
	else PC_next = PC + 4;
	// WB
	//R-type의 Dst는 rd, I-type의 Dst는 rt
	//RegDst는 R타입에서만 1
	wr_addr = controls.RegDst ? parsed_inst.rd : parsed_inst.rt;
	wr_data = controls.MemtoReg ? mem_data : alu_result;
	rf.write(wr_addr, wr_data, controls.RegWrite);

	// Update the PC register last ...
	PC = PC_next;

//register read/write 전에 top모듈에 만들었던 것처럼 구현해야함 여기도 추가로..

	return 1;
}


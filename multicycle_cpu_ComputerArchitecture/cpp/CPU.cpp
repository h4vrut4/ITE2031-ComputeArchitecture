#include <iomanip>
#include <iostream>
#include "CPU.h"
#include "globals.h"

#define VERBOSE 0

using namespace std;

CPU::CPU() : currentState(InstFetch) {}

void CPU::init(string inst_file) {
    // Initialize the register file
    rf.init(false);
    // Load the instructions from the MEM
    mem.load(inst_file);
    // Reset the program counter
    PC = 0;
    // Reset microarchitectural state
    IR = 0;
    MDR = 0;
    A = 0;
    B = 0;
    ALUOut = 0;

    // Set the debugging status
    status = CONTINUE;
}

uint32_t CPU::tick() {
	// parsed & control signals (wire)
	CTRL::Controls controls;
    CTRL::ParsedInst Inst;
	uint32_t ext_imm;

	// Default wires and control signals
	uint32_t rs_data, rt_data;
	uint32_t wr_addr; //for register
	uint32_t wr_data; //for register
	uint32_t operand1;
	uint32_t operand2;
	uint32_t alu_result;

	uint32_t mem_data; //메모리에서 읽어오는 용도
    uint32_t addr; //메모리 주소

    // printf("Current State: %s\n", (currentState == InstFetch) ? "InstFetch" :
    //        (currentState == InstDecode) ? "InstDecode" :
    //        (currentState == Execute) ? "Execute" :
    //        (currentState == Memory) ? "Memory" : "WriteBack");
    ctrl.splitInst(IR, &Inst);
    ctrl.controlSignal(currentState, &Inst, &controls);


    // IF,MEM
    addr = (controls.IorD) ? ALUOut : PC;
	mem.memAccess(addr, &mem_data, B, controls.MemRead, controls.MemWrite);
    if(mem_data == 0){ // IF 단계에서 읽어올 명령어가 없으면 종료
        status = TERMINATE;
        return 0;
    }
    // if(controls.IRWrite) IR = mem_data; // IR에 명령어 저장


    // ID
    // printf("rs: %d, rt: %d, rd: %d\n", Inst.rs, Inst.rt, Inst.rd);
	rf.read(Inst.rs, Inst.rt, &rs_data, &rt_data);
    ctrl.signExtend(Inst.immi, controls.SignExtend, &ext_imm);

    // EX
    operand1 = (controls.ALUSrcA) ? A : PC;
    operand2 = 0; //초기화
    if(controls.ALUSrcB == 0) operand2 = B;
    else if(controls.ALUSrcB == 1) operand2 = 4; //PC+4
    else if(controls.ALUSrcB == 2) operand2 = ext_imm; //sign-extended imm
    else if(controls.ALUSrcB == 3) operand2 = ext_imm << 2; //sign-extended imm << 2
	alu.compute(operand1, operand2, Inst.shamt, controls.ALUOp, &alu_result);
    
	// WB
    if(controls.RegDst == 0) wr_addr = Inst.rt;
    else if(controls.RegDst == 1) wr_addr = Inst.rd;
    else if(controls.RegDst == 2) wr_addr = 31; // $ra
    else wr_addr = 0; // default case - 어차피 안에서 write를 안함.
    if(controls.MemtoReg == 0) wr_data = ALUOut;
    else if(controls.MemtoReg == 1) wr_data = MDR;
    else wr_data = 0; // default case - 문제 없으려나..?
    rf.write(wr_addr, wr_data, controls.RegWrite);

    // Update the PC
    if ((controls.PCWriteCond && alu_result == 1) || controls.PCWrite) {
        switch (controls.PCSource) {
            case 0: PC = alu_result; break; // 일반적 PC+4
            case 1: PC = ALUOut; break; // branch target
            case 2: PC = (PC & 0xF0000000) | (Inst.immj << 2); break; // jump
            case 3: PC = A; break; // jr
        }
    }

    if(controls.IRWrite) IR = mem_data; // IR에 명령어 저장
    else MDR = mem_data;
    ALUOut = alu_result;
    A = rs_data;
	B = rt_data;
    // printf("PC: %08x, IR: %08x, A: %08x, B: %08x, ALUOut: %08x, MDR: %08x\n", PC, mem_data, A, B, ALUOut, MDR);
	return 1;
}

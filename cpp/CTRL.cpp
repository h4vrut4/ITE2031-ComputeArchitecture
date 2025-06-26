#include <iostream>
#include "CTRL.h"
#include "ALU.h"
#include "globals.h"

CTRL::CTRL() {}

void CTRL::splitInst(uint32_t IR, ParsedInst *Inst) {
    Inst->opcode = (IR >> 26) & 0x3F;
    Inst->rs = (IR >> 21) & 0x1F;
    Inst->rt = (IR >> 16) & 0x1F;
    Inst->rd = (IR >> 11) & 0x1F;
    Inst->shamt = (IR >> 6) & 0x1F;
    Inst->funct = IR & 0x3F;
    Inst->immi = IR & 0xFFFF;
    Inst->immj = IR & 0x3FFFFFF;
}

void CTRL::controlSignal(CPUState& state, ParsedInst* Inst, Controls* controls) {
    *controls = {};  // 모든 제어 신호 초기화

    // 공통 단계들의 control signal 설정
    if (state == InstFetch) {
        // IF 단계 공통 신호 (모든 명령어 동일)
        controls->MemRead = 1;     // 메모리 읽기
        controls->IRWrite = 1;     // IR에 쓰기 허용
        controls->ALUSrcA = 0;     // PC를 ALU 입력으로
        controls->ALUSrcB = 1;     // 4를 ALU 입력으로 (PC+4)
        controls->ALUOp = ALU_ADDU;// ADD 연산 (PC+4)
        controls->PCWrite = 1;     // PC 업데이트
        controls->PCSource = 0;    // PC+4
        controls->IorD = 0;         // PC를 주소로 사용
        state = InstDecode;
        return;
    }
    
    if (state == InstDecode) {
        // ID 단계 공통 신호 (모든 명령어 동일)
        controls->ALUSrcA = 0;     // PC를 ALU 입력으로
        controls->ALUSrcB = 3;     // sign-extended imm << 2를 ALU 입력으로
        controls->ALUOp = ALU_ADDU;// ADD 연산 (PC + offset)
        // 다음 상태를 opcode에 따라 분기
        switch (Inst->opcode) {
            case OP_RTYPE:
                if (Inst->funct == FUNCT_JR) state = Execute;
                else state = Execute;
                break;
            case OP_LW: case OP_SW: state = Execute; break;
            case OP_BEQ: case OP_BNE: state = Execute; break;
            case OP_J: state = Execute; break;
            case OP_JAL: state = Execute; break;
            default: state = Execute; break;
        }
        return;
    }

    // EX, MEM, WB 단계는 명령어 타입에 따라 다르게 처리
    if (Inst->opcode == OP_RTYPE) {
        switch(state) {
            case Execute:
                controls->ALUSrcA = 1;  // A
                controls->ALUSrcB = 0;  // B
                
                if (Inst->funct == FUNCT_JR) {
                    controls->PCSource = 3; // jr
                    controls->PCWrite = 1;   // PC 업데이트
                    state = InstFetch;
                } else {
                    switch(Inst->funct) {
                        case FUNCT_SLL:  controls->ALUOp = ALU_SLL;  break;
                        case FUNCT_SRL:  controls->ALUOp = ALU_SRL;  break;
                        case FUNCT_SRA:  controls->ALUOp = ALU_SRA;  break;
                        case FUNCT_ADDU: controls->ALUOp = ALU_ADDU; break;
                        case FUNCT_SUBU: controls->ALUOp = ALU_SUBU; break;
                        case FUNCT_AND:  controls->ALUOp = ALU_AND;  break;
                        case FUNCT_OR:   controls->ALUOp = ALU_OR;   break;
                        case FUNCT_XOR:  controls->ALUOp = ALU_XOR;  break;
                        case FUNCT_NOR:  controls->ALUOp = ALU_NOR;  break;
                        case FUNCT_SLT:  controls->ALUOp = ALU_SLT;  break;
                        case FUNCT_SLTU: controls->ALUOp = ALU_SLTU; break;
                    }
                    state = WriteBack;
                }
                break;
                
            case WriteBack:
                if (Inst->funct != FUNCT_JR) {
                    controls->RegWrite = 1;
                    controls->RegDst = 1;    // rd
                    controls->MemtoReg = 0;  // ALUOut
                    state = InstFetch;
                }
                break;
            
            default:
                break;
        }
    }
    else if (Inst->opcode == OP_LW || Inst->opcode == OP_SW) {
        switch(state) {
            case Execute:
                controls->ALUSrcA = 1;  // A
                controls->ALUSrcB = 2;  // sign-extended imm
                controls->SignExtend = 1; // sign-extend
                controls->ALUOp = ALU_ADDU;
                state = Memory;
                break;
                
            case Memory:
                controls->IorD = 1;
                if (Inst->opcode == OP_LW) {
                    controls->MemRead = 1;
                    state = WriteBack;
                } else {
                    controls->MemWrite = 1;
                    state = InstFetch;
                }
                break;
                
            case WriteBack:
                if (Inst->opcode == OP_LW) {
                    controls->RegWrite = 1;
                    controls->RegDst = 0;    // rt
                    controls->MemtoReg = 1;  // MDR
                    state = InstFetch;
                }
                break;
            
            default:
                break;
        }
    }
    else if (Inst->opcode == OP_BEQ || Inst->opcode == OP_BNE) {
        if (state == Execute) {
            controls->ALUSrcA = 1;  // A
            controls->ALUSrcB = 0;  // B
            controls->SignExtend = 1; // sign-extend
            controls->ALUOp = (Inst->opcode == OP_BEQ) ? ALU_EQ : ALU_NEQ;
            controls->PCWriteCond = 1;
            controls->PCSource = 1;  // ALUOut
            state = InstFetch;
        }
    }
    else if (Inst->opcode == OP_J) {
        switch (state) {
            case Execute:
                controls->PCWrite = 1;
                controls->PCSource = 2;  // jump address
                state = InstFetch; // 그냥 점프
                break;

            default:
                break;
        }
    }
    else if (Inst->opcode == OP_JAL) {
        switch (state) {
            case Execute:
                // controls->ALUSrcA= 0; // PC
                // controls->ALUSrcB = 1; // 4 
                // controls->ALUOp = ALU_ADDU; // PC + 4
                controls->PCWrite = 1;
                controls->PCSource = 2;  // jump address
                state = WriteBack; // $ra에 PC+4 저장을 위해
                break;

            case WriteBack:
                controls->RegWrite = 1;
                controls->RegDst = 2;    // $ra
                controls->MemtoReg = 0;  // ALUOut (PC+4)

                state = InstFetch;
                break;

            default:
                break;
        }
    }
    else if (Inst->opcode >= OP_ADDIU && Inst->opcode <= OP_LUI) {
        switch(state) {
            case Execute:
                controls->ALUSrcA = 1;  // A
                controls->ALUSrcB = 2;  // sign-extended imm
                
                            // 부호 확장 여부 설정
                if (Inst->opcode == OP_ADDIU || Inst->opcode == OP_SLTI || Inst->opcode == OP_SLTIU) {
                    controls->SignExtend = 1;  // 부호 확장 필요
                } else {
                    controls->SignExtend = 0;  // 부호 확장 불필요
                }

                switch(Inst->opcode) {
                    case OP_ADDIU: controls->ALUOp = ALU_ADDU; break;
                    case OP_SLTI:  controls->ALUOp = ALU_SLT;  break;
                    case OP_SLTIU: controls->ALUOp = ALU_SLTU; break;
                    case OP_ANDI:  controls->ALUOp = ALU_AND;  break;
                    case OP_ORI:   controls->ALUOp = ALU_OR;   break;
                    case OP_XORI:  controls->ALUOp = ALU_XOR;  break;
                    case OP_LUI:   controls->ALUOp = ALU_LUI;  break;
                }
                state = WriteBack;
                break;
                
            case WriteBack:
                controls->RegWrite = 1;
                controls->RegDst = 0;    // rt
                controls->MemtoReg = 0;  // ALUOut
                state = InstFetch;
                break;

            default:
                break;
        }
    }
}
// Sign extension using bitwise shift
//어떤 i타입 Inst는 SignExtend를 하고, 어떤 애는 안하고 그래서 인자로 받아야함.
void CTRL::signExtend(uint32_t immi, uint32_t SignExtend, uint32_t *ext_imm) {
	if (SignExtend && (immi & 0x8000))  //최상위 비트가 1이면 음수이니
        *ext_imm = immi | 0xFFFF0000;   //상위 비트를 1로
    else
        *ext_imm = immi & 0x0000FFFF;   //상위 비트를 0으로(사실 안해도 되는 과정임)
}
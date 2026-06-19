#include <iostream>
#include "CTRL.h"
#include "ALU.h"
#include "globals.h"


CTRL::CTRL() {}

void CTRL::splitInst(uint32_t inst, ParsedInst *parsed_inst) {
	parsed_inst->opcode = (inst >> 26) & 0x3F; //6bit
	parsed_inst->rs = (inst >> 21) & 0x1F; //5bit
	parsed_inst->rt = (inst >> 16) & 0x1F; //5bit
	parsed_inst->rd = (inst >> 11) & 0x1F; //5bit
	parsed_inst->shamt = (inst >> 6) & 0x1F; //5bit
	parsed_inst->funct = inst & 0x3F; //6bit
	parsed_inst->immi =  inst & 0xFFFF; //16bit
	parsed_inst->immj =  inst & 0x3FFFFFF;//26bit
}

void CTRL::controlSignal(uint32_t opcode, uint32_t funct, Controls *controls) {
	*controls = {};
    switch(opcode){
        case OP_RTYPE: //R-type이면 funct로 ALUOp 결정
            controls->RegDst = 1;
            controls->RegWrite = 1;
            controls->JR = (funct == FUNCT_JR) ? 1 : 0;
            switch(funct){
                case FUNCT_SLL:  controls->ALUOp = ALU_SLL;  break;
                case FUNCT_SRL:  controls->ALUOp = ALU_SRL;  break;
                case FUNCT_SRA:  controls->ALUOp = ALU_SRA;  break;
                case FUNCT_JR:   break; //JR은 연산 안함.
                case FUNCT_ADDU: controls->ALUOp = ALU_ADDU; break;
				case FUNCT_SUBU: controls->ALUOp = ALU_SUBU; break;
                case FUNCT_AND:  controls->ALUOp = ALU_AND;  break;
                case FUNCT_OR:   controls->ALUOp = ALU_OR;   break;
                case FUNCT_XOR:  controls->ALUOp = ALU_XOR;  break;
                case FUNCT_NOR:  controls->ALUOp = ALU_NOR;  break;
                case FUNCT_SLT:  controls->ALUOp = ALU_SLT;  break;
                case FUNCT_SLTU: controls->ALUOp = ALU_SLTU; break;
                default: status = UNSUPPORTED_ALU; break;
            }
            break;
        case OP_J:
            controls->Jump = 1;
            break;
        case OP_JAL:
            controls->RegWrite = 1; //r31에 pc 저장해야하니까
            controls->Jump = 1;
            controls->SavePC = 1; //분기하면서 돌아올 pc값 저장하라는 신호
            break;
        case OP_BEQ:
            controls->Branch = 1;
            controls->ALUOp = ALU_EQ;
            controls->SignExtend = 1;
            break;
		case OP_BNE:
            controls->Branch = 1;
            controls->ALUOp = ALU_NEQ;
            controls->SignExtend = 1;
            break;
        case OP_ADDIU:
            controls->RegWrite = 1;
            controls->ALUSrc = 1; //imm값 써서
            controls->ALUOp = ALU_ADDU; //ADDU로 처리
            controls->SignExtend = 1;
            break;
        case OP_SLTI:
            controls->RegWrite = 1;
            controls->ALUSrc = 1;
            controls->ALUOp = ALU_SLT;
            controls->SignExtend = 1;
            break;
        case OP_SLTIU:
            controls->RegWrite = 1;
            controls->ALUSrc = 1;
            controls->ALUOp = ALU_SLTU;
            controls->SignExtend = 1;
            break;
        case OP_ANDI:
            controls->RegWrite = 1;
            controls->ALUSrc = 1;
            controls->ALUOp = ALU_AND;
            break;
        case OP_ORI:
            controls->RegWrite = 1;
            controls->ALUSrc = 1;
            controls->ALUOp = ALU_OR;
            break;
        case OP_XORI:
            controls->RegWrite = 1;
            controls->ALUSrc = 1;
            controls->ALUOp = ALU_XOR;
            break;
        case OP_LUI:
            controls->RegWrite = 1;
            controls->ALUSrc = 1;
            controls->ALUOp = ALU_LUI;
            break;
        case OP_LW:
            controls->RegWrite = 1;
            controls->ALUSrc = 1;
            controls->MemRead = 1;
            controls->MemtoReg = 1;
            controls->ALUOp = ALU_ADDU;
            controls->SignExtend = 1;
            break;
        case OP_SW:
            controls->ALUSrc = 1;
            controls->MemWrite = 1;
            controls->ALUOp = ALU_ADDU;
            controls->SignExtend = 1;
            break;
        default:
            status = INVALID_INST;
            break;
    }
}
// Sign extension using bitwise shift
//어떤 i타입 inst는 SignExtend를 하고, 어떤 애는 안하고 그래서 인자로 받아야함.
void CTRL::signExtend(uint32_t immi, uint32_t SignExtend, uint32_t *ext_imm) {
	if (SignExtend && (immi & 0x8000))  //최상위 비트가 1이면 음수이니
        *ext_imm = immi | 0xFFFF0000;   //상위 비트를 1로
    else
        *ext_imm = immi & 0x0000FFFF;   //상위 비트를 0으로(사실 안해도 되는 과정임)
}
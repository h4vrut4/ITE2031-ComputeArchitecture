#ifndef CTRL_H
#define CTRL_H

#include <stdint.h>
class CTRL
{
public:
	CTRL();
	// You can fix these if you want ...
	struct Controls
	{
		uint32_t RegDst;
		uint32_t Jump; // 다음 pc는 jump나 branch에서 결정됨됨
		uint32_t Branch;
		uint32_t JR;
		uint32_t MemRead;
		uint32_t MemtoReg;
		uint32_t MemWrite;
		uint32_t ALUSrc;
		uint32_t SignExtend;
		uint32_t RegWrite;
		uint32_t ALUOp;
		uint32_t SavePC; // Jal inst 실행 시, 돌아올 pc 저장해라.(jump하면서 pc+4를 31번레지스터(ra)에 저장.) 어? pdf랑 다르넹..
	};
	struct ParsedInst
	{
		uint32_t opcode;
		uint32_t rs;
		uint32_t rt;
		uint32_t rd;
		uint32_t shamt;
		uint32_t funct;
		uint32_t immi; // 16bit
		uint32_t immj; // 26bit
	};
	void splitInst(uint32_t inst, ParsedInst *parsed_inst);
	void controlSignal(uint32_t opcode, uint32_t funct, Controls *controls);
	void signExtend(uint32_t immi, uint32_t SignExtend, uint32_t *ext_imm);
};

#endif // CTRL_H

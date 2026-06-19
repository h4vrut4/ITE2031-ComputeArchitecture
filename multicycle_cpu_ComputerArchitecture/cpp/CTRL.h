#ifndef CTRL_H
#define CTRL_H

#include <stdint.h>

enum CPUState {
    InstFetch,
    InstDecode,
    Execute,
    Memory,
    WriteBack
};

class CTRL {
public:
    CTRL();
    struct Controls {
        // PC 관련 제어 신호
        uint32_t PCWrite;      //PC 업데이트 허용
        uint32_t PCWriteCond;  //조건부 PC 업데이트 (beq, bne)
        
        // 메모리 관련 제어 신호
        uint32_t MemRead;      // 메모리 읽기
        uint32_t MemWrite;     // 메모리 쓰기
        uint32_t IorD;         // 0: PC를 주소로 사용, 1: ALUOut을 주소로 사용
        
        // IR 관련 제어 신호
        uint32_t IRWrite;      // IR 레지스터 쓰기 허용
        
        // 레지스터 파일 관련 제어 신호
        uint32_t RegDst;       // 0: rt, 1: rd
        uint32_t RegWrite;     // 레지스터 파일 쓰기
        uint32_t MemtoReg;     // 0: ALUOut, 1: MDR
        
        // ALU 관련 제어 신호
        uint32_t ALUSrcA;      // 0: PC, 1: A 레지스터
        uint32_t ALUSrcB;      // 2비트: 00: B, 01: 4, 10: sign-extended imm, 11: sign-extended imm << 2
        uint32_t ALUOp;        // 2비트: 00: add, 01: subtract, 10: funct field에 따라, 11: not used
        
        // 분기 관련 제어 신호
        uint32_t PCSource;     // 2비트: 00: PC+4, 01: ALUOut, 10: jump address, 11: register value

		uint32_t SignExtend;
    };
    struct ParsedInst {
        uint32_t opcode;
        uint32_t rs;
        uint32_t rt;
        uint32_t rd;
        uint32_t shamt;
        uint32_t funct;
        uint32_t immi; //16bit
        uint32_t immj; //26bit
    };
    void splitInst(uint32_t inst, ParsedInst *parsed_inst);
    void controlSignal(CPUState& state, ParsedInst* inst, Controls* controls);
	void signExtend(uint32_t immi, uint32_t SignExtend, uint32_t *ext_imm);
};

#endif // CTRL_H
#ifndef CPU_H
#define CPU_H


#include <stdint.h>
#include "ALU.h"
#include "RF.h"
#include "CTRL.h"
#include "MEM.h"


class CPU {   
public:
    CPU();
    void init(std::string inst_file);
    uint32_t tick(); // 각 사이클마다 한 상태씩 진행
    ALU alu;
    RF rf;
    CTRL ctrl;
	MEM mem;

	// Act like a storage element
	uint32_t PC;
    CPUState currentState;

private:
    uint32_t IR;    // Instruction Register
    uint32_t MDR;   // Memory Data Register
    uint32_t A;     // ALU input A
    uint32_t B;     // ALU input B
    uint32_t ALUOut;
};

#endif // CPU_H
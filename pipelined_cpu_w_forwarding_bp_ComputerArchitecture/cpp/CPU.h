#ifndef CPU_H
#define CPU_H


#include <stdint.h>
#include "ALU.h"
#include "RF.h"
#include "MEM.h"
#include "CTRL.h"
#include "HAZARD.h"
#include "FORWARDING.h"
#include "BP.h"

class CPU {
public:
    CPU(); // Constructor
	void init(std::string inst_file);
    uint32_t tick(); // Run simulation
    ALU alu;
    RF rf;
    CTRL ctrl;
	MEM mem;
    BranchPredictor predictor;

	// Act like a storage element
	uint32_t PC;
};

struct IF_ID_Latch {
    uint32_t PC;
    uint32_t instruction;
    uint32_t predicted_taken;
    
};

struct ID_EX_Latch { //{}로 flush할 수 있도록 초기값 설정.
    uint32_t PC = 0;
    uint32_t rs_data = 0; //from parsed_inst
    uint32_t rt_data = 0; //from parsed_inst
    uint32_t ext_imm = 0; //signExtend되어있음.
    uint32_t shamt = 0; //from parsed_inst

    uint32_t rs = 0; //FORWARDING을 위해 추가.
    uint32_t rt = 0; //후에 EX단계에서 RegDst로 rt, rd중 하나를 wr_addr로 설정
    uint32_t rd = 0;
    CTRL::Controls controls = {};

    uint32_t immj = 0; //jump연산을 위해 남겨둠

};

struct EX_MEM_Latch {
    uint32_t PC;
    uint32_t alu_result;
    //alu_result를 들고 있으니.. Zero flag는 굳이 만들지 않겠다.
    //EQ, NEQ로 연산하니까 1이면 branch통과
    // uint32_t rs_data; //JR연산을 위해 남겨둠
    uint32_t rt_data;
    uint32_t wr_addr;
    CTRL::Controls controls;

    uint32_t immj; //jump연산을 위해 남겨둠
};

struct MEM_WB_Latch {
    uint32_t PC; //JAL의 경우 r31에 PC를 저장해야해서 필요.
    uint32_t mem_data;
    uint32_t alu_result;
    uint32_t wr_addr;
    CTRL::Controls controls;
};

#endif // CPU_H


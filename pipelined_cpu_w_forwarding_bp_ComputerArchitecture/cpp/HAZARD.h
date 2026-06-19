#ifndef HAZARD_H
#define HAZARD_H

#include "CTRL.h"

// register값 사용하는지 여부 반환하는 함수 선언
uint32_t usesRS(uint32_t opcode);
uint32_t usesRT(uint32_t opcode, uint32_t funct);

// Hazard Detection 함수 선언
// uint32_t detectHazard(uint32_t opcode, uint32_t funct, uint32_t rs, uint32_t rt,
//                       uint32_t id_ex_rd, uint32_t id_ex_rt, uint32_t id_ex_RegWrite,
//                       uint32_t ex_mem_wr_addr, uint32_t ex_mem_RegWrite,
//                       uint32_t mem_wb_wr_addr, uint32_t mem_wb_RegWrite);
uint32_t detectHazard(uint32_t opcode, uint32_t funct, uint32_t rs, uint32_t rt,
                      uint32_t id_ex_rt, uint32_t id_ex_MemRead);
#endif // HAZARD_H
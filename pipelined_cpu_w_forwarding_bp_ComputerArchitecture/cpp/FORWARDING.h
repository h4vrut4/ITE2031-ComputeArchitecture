#ifndef FORWARDING_H
#define FORWARDING_H

#include <stdint.h>

struct ForwardingSignals{
    uint32_t ForwardA; // 0: register file, 1: WB, 2: EX
    uint32_t ForwardB;
};

void computeForwarding(uint32_t id_ex_rs, uint32_t id_ex_rt,
                       uint32_t ex_mem_wr_addr, uint32_t ex_mem_RegWrite,
                       uint32_t mem_wb_wr_addr, uint32_t mem_wb_RegWrite,
                       ForwardingSignals *fw);

#endif

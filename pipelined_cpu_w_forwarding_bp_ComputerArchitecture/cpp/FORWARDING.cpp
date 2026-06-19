#include "FORWARDING.h"

void computeForwarding(uint32_t id_ex_rs, uint32_t id_ex_rt,
                       uint32_t ex_mem_wr_addr, uint32_t ex_mem_RegWrite,
                       uint32_t mem_wb_wr_addr, uint32_t mem_wb_RegWrite,
                       ForwardingSignals *fw)
{

    // ForwardA
    if (ex_mem_RegWrite && ex_mem_wr_addr != 0 && ex_mem_wr_addr == id_ex_rs)
        fw->ForwardA = 2;
    else if (mem_wb_RegWrite && mem_wb_wr_addr != 0 && mem_wb_wr_addr == id_ex_rs)
        fw->ForwardA = 1;
    else
        fw->ForwardA = 0;

    // ForwardB
    if (ex_mem_RegWrite && ex_mem_wr_addr != 0 && ex_mem_wr_addr == id_ex_rt)
        fw->ForwardB = 2;
    else if (mem_wb_RegWrite && mem_wb_wr_addr != 0 && mem_wb_wr_addr == id_ex_rt)
        fw->ForwardB = 1;
    else
        fw->ForwardB = 0;
}
#include "HAZARD.h"
#include "globals.h"

uint32_t usesRS(uint32_t opcode) {
    switch (opcode) {
        case OP_RTYPE: // R-type 명령어
            return 1; // R-type은 항상 rs를 사용
        case OP_LW:    // Load Word
        case OP_SW:    // Store Word
        case OP_BEQ:   // Branch Equal
        case OP_BNE:   // Branch Not Equal
        case OP_ADDIU: // Add Immediate Unsigned
        case OP_SLTI:  // Set Less Than Immediate
        case OP_SLTIU: // Set Less Than Immediate Unsigned
        case OP_ANDI:  // AND Immediate
        case OP_ORI:   // OR Immediate
        case OP_XORI:  // XOR Immediate
            return 1; // rs를 사용
        case OP_J:     // Jump
        case OP_JAL:   // Jump and Link
            return 0; // rs를 사용하지 않음
        default:
            return 0; // 기본적으로 사용하지 않음
    }
}

uint32_t usesRT(uint32_t opcode, uint32_t funct) {
    switch (opcode) {
        case OP_RTYPE: // R-type 명령어
            if (funct == FUNCT_JR) {
                return 0; // JR은 rt를 사용하지 않음
            }
            return 1; // 다른 R-type 명령어는 rt를 사용
        case OP_SW:    // Store Word
        case OP_BEQ:   // Branch Equal
        case OP_BNE:   // Branch Not Equal
            return 1; // rt를 사용
        case OP_LW:    // Load Word
        case OP_ADDIU: // Add Immediate Unsigned
        case OP_SLTI:  // Set Less Than Immediate
        case OP_SLTIU: // Set Less Than Immediate Unsigned
        case OP_ANDI:  // AND Immediate
        case OP_ORI:   // OR Immediate
        case OP_XORI:  // XOR Immediate
        case OP_LUI:   // Load Upper Immediate
        case OP_J:     // Jump
        case OP_JAL:   // Jump and Link
            return 0; // rt를 사용하지 않음
        default:
            return 0; // 기본적으로 사용하지 않음
    }
}

uint32_t detectHazard(uint32_t opcode, uint32_t funct, uint32_t rs, uint32_t rt,
                      uint32_t id_ex_rd, uint32_t id_ex_rt, uint32_t id_ex_RegWrite,
                      uint32_t ex_mem_wr_addr, uint32_t ex_mem_RegWrite,
                      uint32_t mem_wb_wr_addr, uint32_t mem_wb_RegWrite) {
    uint32_t use_rs = usesRS(opcode);
    uint32_t use_rt = usesRT(opcode, funct);

    //Stall Cycle 계산
    if (id_ex_RegWrite && 
        ((id_ex_rd == rs && use_rs) ||
         (id_ex_rd == rt && use_rt) ||
         (id_ex_rt == rs && use_rs) ||
         (id_ex_rt == rt && use_rt))) {
        return 3; // EX 단계에서 매칭
    }

    if (ex_mem_RegWrite &&
        ((ex_mem_wr_addr == rs && use_rs) ||
         (ex_mem_wr_addr == rt && use_rt))) {
        return 2; // MEM 단계에서 매칭
    }

    if (mem_wb_RegWrite &&
        ((mem_wb_wr_addr == rs && use_rs) ||
         (mem_wb_wr_addr == rt && use_rt))) {
        return 1; // WB 단계에서 매칭
    }

    return 0; // Hazard 없음
}
`timescale 1ns / 1ps
`include "GLOBAL.v"

module HAZARD(
    input [5:0]         opcode,       // Current instruction opcode
    input [5:0]         funct,        // Current instruction funct (for R-type)
    input [4:0]         rs,           // Source register rs
    input [4:0]         rt,           // Source register rt
    input [4:0]         ID_EX_rd,     // Destination register in ID/EX stage
    input [4:0]         ID_EX_rt,     // Source register rt in ID/EX stage
    input               ID_EX_RegWrite, // RegWrite signal in ID/EX stage
    input [4:0]         EX_MEM_wr_addr, // Destination register in EX/MEM stage
    input               EX_MEM_RegWrite, // RegWrite signal in EX/MEM stage
    input [4:0]         MEM_WB_wr_addr,  // Destination register in MEM/WB stage
    input               MEM_WB_RegWrite, // RegWrite signal in MEM/WB stage

    output reg [1:0]          hazard_stall         // Stall signal
);

    // Internal signals
    reg use_rs;
    reg use_rt;
    reg [1:0] stall_tmp;

    // Determine if the instruction uses rs
    always @(*) begin
        case (opcode)
            `OP_RTYPE: use_rs = 1; // R-type always uses rs
            `OP_LW, `OP_SW, `OP_BEQ, `OP_BNE, `OP_ADDIU, `OP_SLTI, `OP_SLTIU,
            `OP_ANDI, `OP_ORI, `OP_XORI: use_rs = 1; // These instructions use rs
            `OP_J, `OP_JAL: use_rs = 0; // J and JAL do not use rs
            default: use_rs = 0; // Default case
        endcase
    end

    // Determine if the instruction uses rt
    always @(*) begin
        case (opcode)
            `OP_RTYPE: use_rt = (funct != `FUNCT_JR); // R-type uses rt except JR
            `OP_SW, `OP_BEQ, `OP_BNE: use_rt = 1; // These instructions use rt
            `OP_LW, `OP_ADDIU, `OP_SLTI, `OP_SLTIU,
            `OP_ANDI, `OP_ORI, `OP_XORI, `OP_LUI,
            `OP_J, `OP_JAL: use_rt = 0; // These instructions do not use rt
            default: use_rt = 0; // Default case
        endcase
    end

    // Detect RAW Hazard
    always @(*) begin
        stall_tmp = 0;

        if (ID_EX_RegWrite &&        // ID/EX hazard (stall = 3)
            (((ID_EX_rd == rs) && (rs != 0) && use_rs) || 
             ((ID_EX_rd == rt) && (rt != 0) && use_rt) || 
             ((ID_EX_rt == rs) && (rs != 0) && use_rs) || 
             ((ID_EX_rt == rt) && (rt != 0) && use_rt))) begin
            stall_tmp = 3;
        end else if (EX_MEM_RegWrite &&         // EX/MEM hazard (stall = 2)
            (((EX_MEM_wr_addr == rs) && (rs != 0) && use_rs) || 
             ((EX_MEM_wr_addr == rt) && (rt != 0) && use_rt))) begin
            stall_tmp = (stall_tmp < 2) ? 2 : stall_tmp;
        end else if (MEM_WB_RegWrite &&        // MEM/WB hazard (stall = 1)
            (((MEM_WB_wr_addr == rs) && (rs != 0) && use_rs) || 
             ((MEM_WB_wr_addr == rt) && (rt != 0) && use_rt))) begin
            stall_tmp = (stall_tmp < 1) ? 1 : stall_tmp;
        end


        hazard_stall = stall_tmp;
    end
endmodule
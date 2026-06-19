`timescale 1ns / 1ps
`include "GLOBAL.v"

module HAZARD(
    input  [5:0] opcode,       // Current instruction opcode
    input  [5:0] funct,        // For distinguishing JR
    input  [4:0] rs,
    input  [4:0] rt,

    input  [4:0] id_ex_rt,     // Load-use 대상 (EX 단계의 rt)
    input        id_ex_MemRead,

    output reg [1:0] hazard_stall // 0: no stall, 1: 1-cycle, 2: 2-cycle
);

    reg use_rs;
    reg use_rt;

    always @(*) begin
        // ----- rs 사용 여부 판단 -----
        case (opcode)
            `OP_RTYPE,
            `OP_LW, `OP_SW,
            `OP_BEQ, `OP_BNE,
            `OP_ADDIU, `OP_SLTI, `OP_SLTIU,
            `OP_ANDI, `OP_ORI, `OP_XORI:
                use_rs = 1;
            default:
                use_rs = 0;
        endcase
    end

    always @(*) begin
        // ----- rt 사용 여부 판단 -----
        case (opcode)
            `OP_RTYPE:
                use_rt = (funct != `FUNCT_JR);
            `OP_SW, `OP_BEQ, `OP_BNE:
                use_rt = 1;
            default:
                use_rt = 0;
        endcase
    end

    always @(*) begin
        // 기본값: 스톨 없음
        hazard_stall = 0;

        // Load-Use hazard 검사
        if (id_ex_MemRead &&
            ((id_ex_rt == rs && use_rs) ||
             (id_ex_rt == rt && use_rt))) begin

            // BEQ, BNE는 2-cycle stall
            if (opcode == `OP_BEQ || opcode == `OP_BNE)
                hazard_stall = 2;
            else
                hazard_stall = 1;
        end
    end

endmodule

// FORWARDING.v
`timescale 1ns / 1ps

module FORWARDING(
    input  [4:0] id_ex_rs,
    input  [4:0] id_ex_rt,

    input  [4:0] ex_mem_wr_addr,
    input        ex_mem_RegWrite,

    input  [4:0] mem_wb_wr_addr,
    input        mem_wb_RegWrite,

    output reg [1:0] ForwardA,  // 00: RF, 01: WB, 10: EX
    output reg [1:0] ForwardB
);
    always @(*) begin
        // ForwardA
        if (ex_mem_RegWrite && ex_mem_wr_addr != 0 && ex_mem_wr_addr == id_ex_rs)
            ForwardA = 2;
        else if (mem_wb_RegWrite && mem_wb_wr_addr != 0 && mem_wb_wr_addr == id_ex_rs)
            ForwardA = 1;
        else
            ForwardA = 0;

        // ForwardB
        if (ex_mem_RegWrite && ex_mem_wr_addr != 0 && ex_mem_wr_addr == id_ex_rt)
            ForwardB = 2;
        else if (mem_wb_RegWrite && mem_wb_wr_addr != 0 && mem_wb_wr_addr == id_ex_rt)
            ForwardB = 1;
        else
            ForwardB = 0;
    end
endmodule

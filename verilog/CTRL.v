`timescale 1ns / 1ps
`include "GLOBAL.v"

module CTRL(
	// input opcode and funct
	input [5:0] opcode,
	input [5:0] funct,
	// output various ports
	output reg RegDst,
	output reg Jump,
	output reg Branch,
	output reg JR,
	output reg MemRead,
	output reg MemtoReg,
	output reg MemWrite,
	output reg ALUSrc,
	output reg SignExtend,
	output reg RegWrite,
	output reg [3:0] ALUOp,
	output reg SavePC
    );

	always @(*) begin
		RegDst = 0;
		Jump = 0;
		Branch = 0;
		JR = 0;
		MemRead = 0;
		MemtoReg = 0;
		MemWrite = 0;
		ALUSrc = 0;
		SignExtend = 0;
		RegWrite = 0;
		ALUOp = 4'd0; //4bit이므로..
		SavePC = 0;

		case(opcode)
        	`OP_RTYPE: begin//R-type이면 funct로 ALUOp 결정
        	    RegDst = 1;
        	    RegWrite = 1;
        	    JR = (funct == `FUNCT_JR) ? 1 : 0;
        	    case(funct)
        	        `FUNCT_SLL:  ALUOp = `ALU_SLL; 
        	        `FUNCT_SRL:  ALUOp = `ALU_SRL; 
        	        `FUNCT_SRA:  ALUOp = `ALU_SRA; 
        	        `FUNCT_JR:   ALUOp = 4'd0; //JR은 연산 안함.
        	        `FUNCT_ADDU: ALUOp = `ALU_ADDU;
					`FUNCT_SUBU: ALUOp = `ALU_SUBU;
        	        `FUNCT_AND:  ALUOp = `ALU_AND; 
        	        `FUNCT_OR:   ALUOp = `ALU_OR;  
        	        `FUNCT_XOR:  ALUOp = `ALU_XOR; 
        	        `FUNCT_NOR:  ALUOp = `ALU_NOR; 
        	        `FUNCT_SLT:  ALUOp = `ALU_SLT; 
        	        `FUNCT_SLTU: ALUOp = `ALU_SLTU;
				endcase
			end
        	`OP_J: begin
        	    Jump = 1;
			end
        	`OP_JAL: begin
        	    RegWrite = 1; //r31에 pc 저장해야하니까
        	    Jump = 1;
        	    SavePC = 1; //분기하면서 돌아올 pc값 저장하라는 신호
			end
        	`OP_BEQ: begin
        	    Branch = 1;
        	    ALUOp = `ALU_EQ;
        	    SignExtend = 1;
			end
			`OP_BNE: begin
        	    Branch = 1;
        	    ALUOp = `ALU_NEQ;
        	    SignExtend = 1;
			end
        	`OP_ADDIU: begin
        	    RegWrite = 1;
        	    ALUSrc = 1; //imm값 써서
        	    ALUOp = `ALU_ADDU; //ADDU로 처리
        	    SignExtend = 1;
			end
        	`OP_SLTI: begin
        	    RegWrite = 1;
        	    ALUSrc = 1;
        	    ALUOp = `ALU_SLT;
        	    SignExtend = 1;
			end
        	`OP_SLTIU: begin
        	    RegWrite = 1;
        	    ALUSrc = 1;
        	    ALUOp = `ALU_SLTU;
        	    SignExtend = 1;
			end
        	`OP_ANDI: begin
        	    RegWrite = 1;
        	    ALUSrc = 1;
        	    ALUOp = `ALU_AND;
			end
        	`OP_ORI: begin
        	    RegWrite = 1;
        	    ALUSrc = 1;
        	    ALUOp = `ALU_OR;
			end
        	`OP_XORI: begin
        	    RegWrite = 1;
        	    ALUSrc = 1;
        	    ALUOp = `ALU_XOR;
			end
        	`OP_LUI: begin
        	    RegWrite = 1;
        	    ALUSrc = 1;
        	    ALUOp = `ALU_LUI;
			end
        	`OP_LW: begin
        	    RegWrite = 1;
        	    ALUSrc = 1;
        	    MemRead = 1;
        	    MemtoReg = 1;
        	    ALUOp = `ALU_ADDU;
        	    SignExtend = 1;
			end
        	`OP_SW: begin
        	    ALUSrc = 1;
        	    MemWrite = 1;
        	    ALUOp = `ALU_ADDU;
        	    SignExtend = 1;	
			end
		endcase
	end
endmodule

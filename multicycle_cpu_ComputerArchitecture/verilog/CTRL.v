`timescale 1ns / 1ps
`include "GLOBAL.v"

module CTRL(
	// input opcode and funct
	input [5:0] opcode,
	input [5:0] funct,
	input [2:0] state,
	// output various ports
	output reg PCWrite,
	output reg PCWriteCond,
	output reg MemRead,
	output reg MemWrite,
	output reg IorD,
	output reg IRWrite,
	output reg [1:0] RegDst,
	output reg RegWrite,
	output reg MemtoReg,
	output reg ALUSrcA,
	output reg [1:0] ALUSrcB,
	output reg [3:0] ALUOp,
	output reg [1:0] PCSource,
	output reg SignExtend,
	output reg [2:0] nextState
    );

	//CPUState 정의
	localparam InstFetch  = 3'd0;
	localparam InstDecode = 3'd1;
	localparam Execute    = 3'd2;
	localparam Memory	  = 3'd3;
	localparam WriteBack  = 3'd4;

	always @(*) begin
		PCWrite = 0;
		PCWriteCond = 0;
		MemRead = 0;
		MemWrite = 0;
		MemtoReg = 0;
		IorD = 0;
		IRWrite = 0;
		RegDst = 2'd0;
		RegWrite = 0;
		ALUSrcA = 0;
		ALUSrcB = 2'd0;
		ALUOp = 4'd0;
		PCSource = 2'd0;
		SignExtend = 0;
		nextState = state;

    	case (state)
    	    InstFetch: begin
    	        MemRead = 1;
    	        IRWrite = 1;
    	        ALUSrcA = 0;
    	        ALUSrcB = 2'd1; // 4
    	        ALUOp = `ALU_ADDU;
    	        PCWrite = 1;
    	        PCSource = 0;
    	        IorD = 0;
    	        nextState = InstDecode;
    	    end

    	    InstDecode: begin
    	        ALUSrcA = 0;
    	        ALUSrcB = 2'd3; // imm << 2
    	        ALUOp = `ALU_ADDU;
    	        case (opcode)
    	            `OP_RTYPE: nextState = Execute;
    	            `OP_LW, `OP_SW,
    	            `OP_BEQ, `OP_BNE,
    	            `OP_J, `OP_JAL: nextState = Execute;
    	            default: nextState = Execute;
    	        endcase
    	    end

    	    Execute: begin
    	        case (opcode)
    	            `OP_RTYPE: begin
						ALUSrcA = 1;
    	                ALUSrcB = 2'd0;
    	                case (funct)
    	                    `FUNCT_JR: begin
    	                        PCWrite = 1;
    	                        PCSource = 2'd3;
    	                        nextState = InstFetch;
    	                    end
    	                    default: begin
    	                        case (funct)
    	                            `FUNCT_ADDU: ALUOp = `ALU_ADDU;
    	                            `FUNCT_SUBU: ALUOp = `ALU_SUBU;
    	                            `FUNCT_AND:  ALUOp = `ALU_AND;
    	                            `FUNCT_OR:   ALUOp = `ALU_OR;
    	                            `FUNCT_XOR:  ALUOp = `ALU_XOR;
    	                            `FUNCT_NOR:  ALUOp = `ALU_NOR;
    	                            `FUNCT_SLT:  ALUOp = `ALU_SLT;
    	                            `FUNCT_SLTU: ALUOp = `ALU_SLTU;
    	                            `FUNCT_SLL:  ALUOp = `ALU_SLL;
    	                            `FUNCT_SRL:  ALUOp = `ALU_SRL;
    	                            `FUNCT_SRA:  ALUOp = `ALU_SRA;
    	                        endcase
    	                        nextState = WriteBack;
    	                    end
    	                endcase
    	            end

    	            `OP_LW, `OP_SW: begin
						ALUSrcA = 1;
    	                ALUSrcB = 2'd2;
    	                SignExtend = 1;
    	                ALUOp = `ALU_ADDU;
    	                nextState = Memory;
    	            end

    	            `OP_BEQ, `OP_BNE: begin
						ALUSrcA = 1;
    	                ALUSrcB = 2'd0;
    	                SignExtend = 1;
    	                ALUOp = (opcode == `OP_BEQ) ? `ALU_EQ : `ALU_NEQ;
    	                PCWriteCond = 1;
    	                PCSource = 2'd1;
    	                nextState = InstFetch;
    	            end

    	            `OP_J: begin
						ALUSrcA = 1;
    	                PCWrite = 1;
    	                PCSource = 2'd2;
    	                nextState = InstFetch;
    	            end

    	            `OP_JAL: begin
    	                PCWrite = 1;
    	                PCSource = 2'd2;
    	                nextState = WriteBack;
    	            end

    	            `OP_ADDIU, `OP_SLTI, `OP_SLTIU,
    	            `OP_ANDI, `OP_ORI, `OP_XORI, `OP_LUI: begin
						ALUSrcA = 1;
    	                ALUSrcB = 2'd2;
    	                case (opcode)
    	                    `OP_ADDIU, `OP_SLTI, `OP_SLTIU: SignExtend = 1;
    	                    default: SignExtend = 0;
    	                endcase

    	                case (opcode)
    	                    `OP_ADDIU: ALUOp = `ALU_ADDU;
    	                    `OP_SLTI:  ALUOp = `ALU_SLT;
    	                    `OP_SLTIU: ALUOp = `ALU_SLTU;
    	                    `OP_ANDI:  ALUOp = `ALU_AND;
    	                    `OP_ORI:   ALUOp = `ALU_OR;
    	                    `OP_XORI:  ALUOp = `ALU_XOR;
    	                    `OP_LUI:   ALUOp = `ALU_LUI;
    	                endcase
    	                nextState = WriteBack;
    	            end
    	        endcase
    	    end

			Memory: begin
				case (opcode)
					`OP_LW: begin
						IorD = 1;
						MemRead = 1;
						nextState = WriteBack;
					end

					`OP_SW: begin
						IorD = 1;
						MemWrite = 1;
						nextState = InstFetch;
					end
				endcase
			end

    	    WriteBack: begin
    	        case (opcode)
    	            `OP_RTYPE: begin
    	                RegWrite = 1;
    	                RegDst = 2'd1;
    	                MemtoReg = 0;
    	                nextState = InstFetch;
    	            end

    	            `OP_LW: begin
    	                RegWrite = 1;
    	                RegDst = 2'd0;
    	                MemtoReg = 1;
    	                nextState = InstFetch;
    	            end

    	            `OP_JAL: begin
    	                RegWrite = 1;
    	                RegDst = 2'd2;
    	                MemtoReg = 0;
    	                nextState = InstFetch;
    	            end

    	            default: begin //i-type 연산들
    	                RegWrite = 1;
    	                RegDst = 2'd0; //rt
    	                MemtoReg = 0; //ALUOut
    	                nextState = InstFetch;
    	            end
    	        endcase
    	    end

    	    default: nextState = InstFetch;
    	endcase
	end	
endmodule

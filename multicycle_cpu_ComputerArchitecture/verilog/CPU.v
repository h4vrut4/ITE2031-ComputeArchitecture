`timescale 1ns / 1ps


module CPU(
	input		clk,
	input		rst,
	output 		halt
	);

    // FSM 상태
    reg [2:0]      currentState;
	localparam     InstFetch  = 3'd0;
	localparam     InstDecode = 3'd1;
	localparam     Execute    = 3'd2;
	localparam     Memory	  = 3'd3;
	localparam     WriteBack  = 3'd4;

    // 주요 레지스터들
    reg [31:0]      PC;
    reg [31:0]      IR;
    reg [31:0]      MDR;
    reg [31:0]      A;
    reg [31:0]      B;
    reg [31:0]      ALUOut;

    //wire [31:0] inst;
    wire [31:0]     mem_data;
    wire [31:0]     mem_addr;
    wire [31:0]     alu_result;
    wire [31:0]     ext_imm;

	wire [31:0]		rd_data1;
	wire [31:0]		rd_data2;
    wire [4:0]      wr_addr;
    wire [31:0]     wr_data;

    // Instruction fields
    wire [5:0]      opcode = IR[31:26];
    wire [4:0]      rs = IR[25:21];
    wire [4:0]      rt = IR[20:16];
    wire [4:0]      rd = IR[15:11];
    wire [4:0]      shamt = IR[10:6];
    wire [5:0]      funct = IR[5:0];
    wire [15:0]     immi = IR[15:0];
    wire [25:0]     immj = IR[25:0];

    // Control signals
    wire			PCWrite;
    wire			PCWriteCond;
    wire			MemRead;
    wire			MemWrite;
    wire			IorD;
    wire			IRWrite;
    wire [1:0]		RegDst;
    wire			RegWrite;
    wire			MemtoReg;
    wire			ALUSrcA;
    wire [1:0]		ALUSrcB;
    wire [3:0]      ALUOp;
    wire [1:0]		PCSource;
    wire			SignExtend;
    wire [2:0]      nextState;

	assign halt		= (IR == 32'b0);

    // Sign Extension
    assign ext_imm = SignExtend ? {{16{immi[15]}}, immi} : {16'b0, immi};
    // MEM 
    assign mem_addr = (IorD) ? ALUOut : PC;
    // WB
    assign wr_addr = (RegDst == 2'd0) ? rt :
                        (RegDst == 2'd1) ? rd :
                        (RegDst == 2'd2) ? 5'd31 : // JAL
                        5'd0; // default
    assign wr_data = (MemtoReg == 1'b0) ? ALUOut : MDR;
    
    // FSM 동작
    always @(posedge clk) begin
        // if (currentState == 2 && opcode == `OP_BEQ) begin
        //     $display("State=%d, PC=%h, rs=%d (rd_addr1=%d), rt=%d (rd_addr2=%d), A=%h, B=%h", currentState, PC, rs, rs, rt, rt, A, B);
        // end
        // if (RegWrite) begin
        //     $display("[WB] PC=%h, wr_addr=%d, wr_data=%h, ALUOut=%h, MDR=%h, MemtoReg=%b", PC, wr_addr, wr_data, ALUOut, MDR, MemtoReg);
        // end
        // if (opcode == `OP_JAL) begin
        //     $display("[JAL1] PC=%h, state=%d, RegWrite=%d, RegDst=%d, MemtoReg=%d, alu_result=%h, ALUOut=%h <-prev ex result",PC, currentState, RegWrite, RegDst, MemtoReg, alu_result, ALUOut);
        //     $display("[JAL2] ALUSrcA=%d, ALUSrcB=%d",ALUSrcA, ALUSrcB);
        //     $display("[JAL3] PCWrite=%d, PCSource=%d // wr_addr=%h, wr_data=%h",PCWrite, PCSource, wr_addr, wr_data);
        // end
        // if (opcode == `OP_RTYPE && funct == `FUNCT_JR) begin
        //     $display("[JR1] PC=%h, state=%d, opcode=%h, RegWrite=%d, RegDst=%d, MemtoReg=%d",PC, currentState, opcode, RegWrite, RegDst, MemtoReg);
        //     $display("[JR2] rs=%d, A=%h, PCWrite=%d, PCSource=%d", rs, A, PCWrite, PCSource);
        // end
        // $display("Cycle=%0t, currentState=%d, nextState=%d, MemtoReg=%b", $time, currentState, nextState, MemtoReg);
        // $display("State=%d, PC=%h, rs=%d (rd_addr1=%d), rt=%d (rd_addr2=%d), A=%h, B=%h", currentState, PC, rs, rs, rt, rt, A, B);


        if (rst) begin //동기적으로 rst
            PC <= 0;
            IR <= 0;
            MDR <= 0;
            A <= 0;
            B <= 0;
            ALUOut <= 0;
            currentState <= InstFetch;
        end else begin
            if (IRWrite) IR <= mem_data;
            else MDR <= mem_data;
            if ((PCWriteCond && alu_result == 1) || PCWrite) begin
                case (PCSource)
                    2'd0: PC <= alu_result;
                    2'd1: PC <= ALUOut;
                    2'd2: PC <= {PC[31:28], immj, 2'b00};
                    2'd3: PC <= A; //JR
                endcase
            end
            A <= rd_data1;
            B <= rd_data2;
            ALUOut <= alu_result;
            currentState <= nextState;
        end
    end
    

    //연결
    CTRL ctrl (
        .opcode(opcode),
        .funct(funct),
        .state(currentState),
        .PCWrite(PCWrite),
        .PCWriteCond(PCWriteCond),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .IorD(IorD),
        .IRWrite(IRWrite),
        .RegDst(RegDst),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .ALUOp(ALUOp),
        .PCSource(PCSource),
        .SignExtend(SignExtend),
        .nextState(nextState)
    );
    RF rf (
        .clk(clk), .rst(rst),
		.rd_addr1(rs), .rd_addr2(rt),
        .rd_data1(rd_data1), .rd_data2(rd_data2),
		.RegWrite(RegWrite),
		.wr_addr(wr_addr), .wr_data(wr_data)
    );
    ALU alu (
        .operand1(ALUSrcA ? A : PC),
        .operand2((ALUSrcB == 2'd0) ? B :
                  (ALUSrcB == 2'd1) ? 32'd4 :
                  (ALUSrcB == 2'd2) ? ext_imm :
                  (ext_imm << 2)),
        .shamt(shamt),
        .funct(ALUOp),
        .alu_result(alu_result)
    );
    MEM mem (
        .clk(clk), .rst(rst),
        .mem_addr(mem_addr), .MemWrite(MemWrite),
        .mem_write_data(B), .mem_read_data(mem_data)
    );

endmodule

`timescale 1ns / 1ps


module CPU(
	input		clk,
	input		rst,
	output 		halt
	);
	
	// Split the instructions
	// Instruction-related wires
	wire [31:0]		inst;
	wire [5:0]		opcode;
	wire [4:0]		rs;
	wire [4:0]		rt;
	wire [4:0]		rd;
	wire [4:0]		shamt;
	wire [5:0]		funct;
	wire [15:0]		immi;
	wire [25:0]		immj;

	// Control-related wires
	wire			RegDst;
	wire			Jump;
	wire 			Branch;
	wire 			JR;
	wire			MemRead;
	wire			MemtoReg;
	wire 			MemWrite;
	wire			ALUSrc;
	wire			SignExtend;
	wire			RegWrite;
	wire [3:0]		ALUOp;
	wire			SavePC;

	// Sign extend the immediate
	wire [31:0]		ext_imm;

	// RF-related wires
	wire [4:0]		rd_addr1; //필요한가?1
	wire [4:0]		rd_addr2; //필요한가?2
	wire [31:0]		rd_data1; //이게 rs
	wire [31:0]		rd_data2; //이게 rt?
	reg [4:0]		wr_addr;
	reg [31:0]		wr_data;

	// MEM-related wires
	wire [31:0]		mem_addr;
	wire [31:0]		mem_write_data;
	wire [31:0]		mem_read_data;

	// ALU-related wires
	wire [31:0]		operand1;
	wire [31:0]		operand2;
	wire [31:0]		alu_result;

	// Define PC
	reg [31:0]	PC;
	reg [31:0]	PC_next;

	// Define the wires
	//현재 instruction의 32bit이 전부 0이면 중지(halt)신호를 1로 설정
	//근데 이걸 다루는 부분이 안보이네
	assign halt				= (inst == 32'b0);

	//splitInst()기능
	assign opcode = inst[31:26];
	assign rs = inst[25:21];
	assign rt = inst[20:16];
	assign rd = inst[15:11];
	assign shamt = inst[10:6];
	assign funct = inst[5:0];
	assign immi = inst[15:0];
	assign immj = inst[25:0];

	//signExtend()기능 - SignExtend가 1이면, 최상위 비트 확인해서 늘려주기
	assign ext_imm = (SignExtend) ? {{16{immi[15]}}, immi} : {16'b0, immi};

	//EX를 위해 operand1,2 값 구하기
	assign operand1 = rd_data1;
	assign operand2 = (ALUSrc) ? ext_imm : rd_data2;

	always @(*) begin
		//WB할 값 결정
		wr_addr = (RegDst) ? rd : rt;
		wr_data = (MemtoReg) ? mem_read_data : alu_result;

		if(JR) PC_next = rd_data1;
		else if(Branch && alu_result) PC_next = PC + 4 + (ext_imm << 2);
		else if(Jump) begin
			if(SavePC) begin
				wr_addr = 5'd31;
				wr_data = PC + 4;
			end
			PC_next = {PC[31:28], (immj << 2)};
		end
		else PC_next = PC + 4;
	end

	// Update the Clock
	always @(posedge clk) begin
		if (rst)	PC <= 0;
		else begin
			PC <= PC_next;
		end
	end
	
	//연결
	CTRL ctrl (.opcode(opcode), .funct(funct),
    	.RegDst(RegDst), .Jump(Jump),
    	.Branch(Branch), .JR(JR),
    	.MemRead(MemRead), .MemtoReg(MemtoReg),
    	.MemWrite(MemWrite), .ALUSrc(ALUSrc),
    	.SignExtend(SignExtend), .RegWrite(RegWrite),
    	.ALUOp(ALUOp), .SavePC(SavePC)
	);
    RF rf (.clk(clk), .rst(rst), 
        .rd_addr1(rs), .rd_addr2(rt),
        .rd_data1(rd_data1), .rd_data2(rd_data2),
        .RegWrite(RegWrite), .wr_addr(wr_addr),
        .wr_data(wr_data)
    );
	MEM mem (
    	.clk(clk), .rst(rst),
    	.inst_addr(PC), .inst(inst),
    	.mem_addr(alu_result), .MemWrite(MemWrite),
    	.mem_write_data(rd_data2), .mem_read_data(mem_read_data)
	);
    ALU alu (.operand1(operand1), .operand2(operand2),
        .shamt(shamt), .funct(ALUOp), //CTRL.v에서 ALUOp에 값을 할당했으므로..(그리고 4bit짜리를 받는다)
        .alu_result(alu_result)    
    );
	
endmodule

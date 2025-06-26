`timescale 1ns / 1ps


module CPU(
	input		clk,
	input		rst,
	output 		halt
	);
	
	// Split the instructions
	// Instruction-related wires
	wire [31:0]		inst;
	wire [5:0]		IF_ID_opcode;
	wire [4:0]		IF_ID_rs;
	wire [4:0]		IF_ID_rt;
	wire [4:0]		IF_ID_rd;
	wire [4:0]		IF_ID_shamt;
	wire [5:0]		IF_ID_funct;
	wire [15:0]		IF_ID_immi;
	wire [25:0]		IF_ID_immj;

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
	wire [4:0]		rd_addr1;
	wire [4:0]		rd_addr2;
	wire [31:0]		rd_data1; //이게 cpp에서 rs_data
	wire [31:0]		rd_data2; //이게 cpp에서 rt_data
	reg [31:0]		wr_data;
	reg [4:0]		wr_addr;
	// MEM-related wires
	wire [31:0]		mem_addr;
	wire [31:0]		mem_write_data;
	wire [31:0]		mem_read_data;

	// ALU-related wires
	wire [31:0]		operand1;
	wire [31:0]		operand2;
	wire [31:0]		alu_result;
	// Define PC
	reg [31:0]		PC;
	reg [31:0]		PC_next;

	// IF/ID latch
	reg [31:0] 		IF_ID_PC;
	reg [31:0] 		IF_ID_instruction;

	// ID/EX latch
	reg [31:0]		ID_EX_PC;
	reg [31:0]		ID_EX_rd_data1; //rs_data
	reg [31:0]		ID_EX_rd_data2; //rt_data
	reg [31:0]		ID_EX_ext_imm;
	reg [4:0]		ID_EX_rt;
	reg [4:0]		ID_EX_rd; //후에 EX단계에서 RegDst로 rt, rd 중 하나를 wr_addr로 설정
	reg [4:0]		ID_EX_shamt;
	reg				ID_EX_RegDst;
	reg				ID_EX_ALUSrc;
	reg [3:0]		ID_EX_ALUOp; //branch 고려할 때에도 사용할 예정. (Controls가 없으니..)
	reg   			ID_EX_MemtoReg;
	reg 			ID_EX_MemRead;
	reg 			ID_EX_MemWrite;
	reg 			ID_EX_RegWrite;
	reg [31:0]		ID_EX_immj;
	reg 			ID_EX_Branch;
	reg 			ID_EX_Jump;
	reg 			ID_EX_JR;
	reg 			ID_EX_SavePC;
	

	// EX/MEM latch
	reg [31:0]		EX_MEM_PC;
	reg [31:0]		EX_MEM_alu_result;
	reg [31:0]		EX_MEM_rd_data2; //rt_data
	reg [4:0]		EX_MEM_wr_addr;
	reg   			EX_MEM_MemtoReg;
	reg 			EX_MEM_MemRead;
	reg 			EX_MEM_MemWrite;
	reg 			EX_MEM_RegWrite;
	reg 			EX_MEM_SavePC;


	// MEM/WB latch
	reg [31:0]		MEM_WB_PC;
	reg [31:0]		MEM_WB_alu_result;
	reg [31:0]		MEM_WB_mem_read_data;
	reg [4:0]		MEM_WB_wr_addr;
	reg   			MEM_WB_MemtoReg;
	reg 			MEM_WB_SavePC;
	reg 			MEM_WB_RegWrite;

	// Define the wires
	reg 			misprediction_detected;
	wire [1:0] 		hazard_stall; // HAZARD 모듈에서 생성된 stall 신호
	//현재 instruction의 32bit이 전부 0이면 중지(halt)신호를 1로 설정
	reg [2:0]   	delay_cycles;  //3'b110; 틱 튈때마다,  inst == 32'b0 체크하고 1씩 줄이다가, 0되는 순간 halt 신호를 1로 설정
	assign halt		= (delay_cycles == 3'b0);
	//halt 바로 안되게 설정하는 로직 필요

	//splitInst()기능
	assign IF_ID_opcode = IF_ID_instruction[31:26];
	assign IF_ID_rs = IF_ID_instruction[25:21];
	assign IF_ID_rt = IF_ID_instruction[20:16];
	assign IF_ID_rd = IF_ID_instruction[15:11];
	assign IF_ID_shamt = IF_ID_instruction[10:6];
	assign IF_ID_funct = IF_ID_instruction[5:0];
	assign IF_ID_immi = IF_ID_instruction[15:0];
	assign IF_ID_immj = IF_ID_instruction[25:0];

	//signExtend()기능 - SignExtend가 1이면, 최상위 비트 확인해서 늘려주기
	assign ext_imm = (SignExtend) ? {{16{IF_ID_immi[15]}}, IF_ID_immi} : {16'b0, IF_ID_immi};

	//EX를 위해 operand1,2 값 구하기
	assign operand1 = ID_EX_rd_data1;
	assign operand2 = (ID_EX_ALUSrc) ? ID_EX_ext_imm : ID_EX_rd_data2;

	always @(*) begin
		//WB할 값 결정
		wr_data = (MEM_WB_MemtoReg) ? MEM_WB_mem_read_data : MEM_WB_alu_result;
		if(MEM_WB_SavePC) begin
			wr_addr = 5'd31;
			wr_data = MEM_WB_PC + 4;
		end else begin
			wr_addr = MEM_WB_wr_addr;
		end

		// //감지된 stall 신호 가져오기
		// if (hazard_stall != 0) stall = hazard_stall;

		//Branch ID단계에서 계산.
		//탐지하는 값을 IF_ID 값으로 해야함.(수정 필요)
		misprediction_detected = 0;
		if(JR) begin
			PC_next = rd_data1;
			misprediction_detected = 1;
		end else if(Branch && ALUOp == `ALU_EQ && rd_data1 == rd_data2) begin
			PC_next = IF_ID_PC + 4 + (ext_imm << 2);
			misprediction_detected = 1;
		end	else if(Branch && ALUOp == `ALU_NEQ && rd_data1 != rd_data2) begin
		 	PC_next = IF_ID_PC + 4 + (ext_imm << 2);
			misprediction_detected = 1;
		end else if(Jump) begin
			PC_next = {IF_ID_PC[31:28], (IF_ID_immj << 2)};
			misprediction_detected = 1;
		end else begin
			PC_next = PC + 4;
		end
	end

	// Update the Clock
	always @(posedge clk) begin
		// $display("PC: %h, inst: %h", PC, inst);
		// $display("IF_ID_PC: %h, IF_ID_instruction: %h", IF_ID_PC, IF_ID_instruction);
		// $display("rs: %h, rt: %h", IF_ID_rs, IF_ID_rt);
		// $display("ID_EX_PC: %h, ID_EX_RegWrite: %d, ID_EX_rd: %h, ID_EX_rt: %h",ID_EX_PC, ID_EX_RegWrite, ID_EX_rd, ID_EX_rt);
		// $display("EX_MEM_PC: %h, EX_MEM_RegWrite: %d, EX_MEM_wr_addr: %h", EX_MEM_PC, EX_MEM_RegWrite, EX_MEM_wr_addr);
		// $display("MEM_WB_PC: %h, MEM_WB_RegWrite: %d, MEM_WB_wr_addr: %h, MEM_WB_wr_data: %h",MEM_WB_PC, MEM_WB_RegWrite, MEM_WB_wr_addr, wr_data);
		// $display("Hazard_stall: %d", hazard_stall);
		// $display("misprediction: %d", misprediction_detected);
		// $display("=========================");
		if (rst) begin
			PC <= 32'b0;
			misprediction_detected <= 0;
			delay_cycles <= 3'b110; //6으로 설정해두고, delay_cycles가 0이 되면 halt 신호를 1로 설정
									//halt는 delay_cycle 값 바뀌면 바로 업데이트 되어서.. 3'b111로 설정해야 할 수도? {의심}
			//모든 latch 초기화 필요!!!
			IF_ID_PC <= 32'b0;
			IF_ID_instruction <= 32'b0;
			ID_EX_PC <= 32'b0;
			ID_EX_rd_data1 <= 32'b0;
			ID_EX_rd_data2 <= 32'b0;
			ID_EX_ext_imm <= 32'b0;
			ID_EX_rt <= 5'b0;
			ID_EX_rd <= 5'b0;
			ID_EX_shamt <= 5'b0;
			ID_EX_RegDst <= 1'b0;
			ID_EX_ALUSrc <= 1'b0;
			ID_EX_ALUOp <= 4'b0;
			ID_EX_MemtoReg <= 1'b0;
			ID_EX_MemRead <= 1'b0;
			ID_EX_MemWrite <= 1'b0;
			ID_EX_RegWrite <= 1'b0;
			ID_EX_immj <= 32'b0;
			ID_EX_Branch <= 1'b0;
			ID_EX_Jump <= 1'b0;
			ID_EX_JR <= 1'b0;
			ID_EX_SavePC <= 1'b0;
			EX_MEM_PC <= 32'b0;
			EX_MEM_alu_result <= 32'b0;
			EX_MEM_rd_data2 <= 32'b0;
			EX_MEM_wr_addr <= 5'b0;
			EX_MEM_MemtoReg <= 1'b0;
			EX_MEM_MemRead <= 1'b0;
			EX_MEM_MemWrite <= 1'b0;
			EX_MEM_RegWrite <= 1'b0;
			EX_MEM_SavePC <= 1'b0;
			MEM_WB_PC <= 32'b0;
			MEM_WB_alu_result <= 32'b0;
			MEM_WB_mem_read_data <= 32'b0;
			MEM_WB_wr_addr <= 5'b0;
			MEM_WB_MemtoReg <= 1'b0;
			MEM_WB_SavePC <= 1'b0;
			MEM_WB_RegWrite <= 1'b0;
		end else begin
			//Update Latches
			// IF/ID
			
			if(hazard_stall > 0) begin
				PC <= PC;
				IF_ID_PC <= IF_ID_PC;
				IF_ID_instruction <= IF_ID_instruction;	
			end else if (misprediction_detected > 0 && hazard_stall == 0) begin
				PC <= PC_next;
				IF_ID_PC <= 32'b0;
				IF_ID_instruction <= 32'b0;		    
			end else begin
				PC <= PC_next;
        		IF_ID_PC <= PC;
        		IF_ID_instruction <= inst;
			end

			// ID/EX
			if (hazard_stall > 0 || (misprediction_detected > 0 && SavePC == 0)) begin 
				ID_EX_PC <= 0;
				ID_EX_rd_data1 <= 0;
				ID_EX_rd_data2 <= 0;
				ID_EX_ext_imm <= 0;
				ID_EX_rt <= 0;
				ID_EX_rd <= 0;
				ID_EX_shamt <= 0;
				ID_EX_RegDst <= 0;
				ID_EX_ALUSrc <= 0;
				ID_EX_ALUOp <= 0;
				ID_EX_MemtoReg <= 0;
				ID_EX_MemRead <= 0;
				ID_EX_MemWrite <= 0;
				ID_EX_RegWrite <= 0;
				ID_EX_immj <= 0;
				ID_EX_Branch <= 0;
				ID_EX_Jump <= 0;
				ID_EX_JR <= 0;
				ID_EX_SavePC <= 0;
			end else begin //hazard만 아니면 제대로 들어가는거 맞는데
				ID_EX_PC <= IF_ID_PC;
				ID_EX_rd_data1 <= rd_data1;
				ID_EX_rd_data2 <= rd_data2;
				ID_EX_ext_imm <= ext_imm;
				ID_EX_rt <= IF_ID_rt;
				ID_EX_rd <= IF_ID_rd;
				ID_EX_shamt <= IF_ID_shamt;
				ID_EX_RegDst <= RegDst;
				ID_EX_ALUSrc <= ALUSrc;
				ID_EX_ALUOp <= ALUOp;
				ID_EX_MemtoReg <= MemtoReg;
				ID_EX_MemRead <= MemRead;
				ID_EX_MemWrite <= MemWrite;
				ID_EX_RegWrite <= RegWrite;
				ID_EX_immj <= IF_ID_immj;
				ID_EX_Branch <= Branch;
				ID_EX_Jump <= Jump;
				ID_EX_JR <= JR;
				ID_EX_SavePC <= SavePC;
			end

        	// EX/MEM
			EX_MEM_PC <= ID_EX_PC;
			EX_MEM_alu_result <= alu_result;
			EX_MEM_rd_data2 <= ID_EX_rd_data2;
			EX_MEM_wr_addr <= (ID_EX_RegDst) ? ID_EX_rd : ID_EX_rt;
			EX_MEM_MemtoReg <= ID_EX_MemtoReg;
			EX_MEM_MemRead <= ID_EX_MemRead;
			EX_MEM_MemWrite <= ID_EX_MemWrite;
			EX_MEM_RegWrite <= ID_EX_RegWrite;
			EX_MEM_SavePC <= ID_EX_SavePC;

        	// MEM/WB
			MEM_WB_PC <= EX_MEM_PC;
			MEM_WB_alu_result <= EX_MEM_alu_result;
			MEM_WB_mem_read_data <= mem_read_data; //MEM단계에서 생기니까.
			MEM_WB_wr_addr <= EX_MEM_wr_addr;
			MEM_WB_MemtoReg <= EX_MEM_MemtoReg;
			MEM_WB_SavePC <= EX_MEM_SavePC;
			MEM_WB_RegWrite <= EX_MEM_RegWrite;

			//종료 조건
			if (inst == 32'b0 || delay_cycles != 3'b110) begin //종료 조건이 시작되었다면..
				if (hazard_stall == 0 && misprediction_detected == 0)
					delay_cycles <= delay_cycles - 1;
			end
		end
	end
	
	//연결
	CTRL ctrl (.opcode(IF_ID_opcode), .funct(IF_ID_funct),
    	.RegDst(RegDst), .Jump(Jump),
    	.Branch(Branch), .JR(JR),
    	.MemRead(MemRead), .MemtoReg(MemtoReg),
    	.MemWrite(MemWrite), .ALUSrc(ALUSrc),
    	.SignExtend(SignExtend), .RegWrite(RegWrite),
    	.ALUOp(ALUOp), .SavePC(SavePC)
	);
    RF rf (.clk(clk), .rst(rst), 
        .rd_addr1(IF_ID_rs), .rd_addr2(IF_ID_rt), //rs ,rt에 해서 RAW Hazard 탐지 필요
        .rd_data1(rd_data1), .rd_data2(rd_data2),
        .RegWrite(MEM_WB_RegWrite), .wr_addr(wr_addr),
        .wr_data(wr_data)
    );
	MEM mem (
    	.clk(clk), .rst(rst),
    	.inst_addr(PC), .inst(inst),
    	.mem_addr(EX_MEM_alu_result), .MemWrite(EX_MEM_MemWrite),
    	.mem_write_data(EX_MEM_rd_data2), .mem_read_data(mem_read_data)
	);
    ALU alu (.operand1(operand1), .operand2(operand2),
        .shamt(ID_EX_shamt), .funct(ID_EX_ALUOp), //CTRL.v에서 ALUOp에 값을 할당했으므로..(그리고 4bit짜리를 받는다)
        .alu_result(alu_result)    
    );
	// Hazard detection unit
	HAZARD hazard (
		.opcode(IF_ID_opcode), .funct(IF_ID_funct), .rs(IF_ID_rs), .rt(IF_ID_rt),
		.ID_EX_RegWrite(ID_EX_RegWrite), .ID_EX_rd(ID_EX_rd),
		.ID_EX_rt(ID_EX_rt), .EX_MEM_RegWrite(EX_MEM_RegWrite),
		.EX_MEM_wr_addr(EX_MEM_wr_addr), .MEM_WB_RegWrite(MEM_WB_RegWrite),
		.MEM_WB_wr_addr(MEM_WB_wr_addr), 
		.hazard_stall(hazard_stall)
	);
	
endmodule

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
	reg [31:0]		operand1;
	reg [31:0]		operand2;
	wire [31:0]		alu_result;
	// Define PC
	reg [31:0]		PC;
	reg [31:0]		PC_next_for_JR;

	// IF/ID latch
	reg [31:0] 		IF_ID_PC;
	reg [31:0] 		IF_ID_instruction;

	// ID/EX latch
	reg [31:0]		ID_EX_PC;
	reg [31:0]		ID_EX_rd_data1; //rs_data
	reg [31:0]		ID_EX_rd_data2; //rt_data
	reg [31:0]		ID_EX_ext_imm;
	reg [4:0]		ID_EX_rs; //FORWARDING할 때 필요하넹 ㅎㅎ;
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
	reg 			mispredict;
	wire [1:0] 		hazard_stall; // HAZARD 모듈에서 생성된 stall 신호
	//현재 instruction의 32bit이 전부 0이면 중지(halt)신호를 1로 설정
	reg [2:0]   	delay_cycles;  //3'b110; 틱 튈때마다,  inst == 32'b0 체크하고 1씩 줄이다가, 0되는 순간 halt 신호를 1로 설정
	assign halt		= (delay_cycles == 3'b0);
	//halt 바로 안되게 설정하는 로직 필요

	//LAB06에서 추가됨 (FORWARDING, BP를 위한 값들)
	wire [31:0] 	nextPC;
	wire 			predict_taken;
	wire [1:0] 		ForwardA, ForwardB;
	reg [31:0]		Forwarded_rd_data2; //rt_data
    reg           	actually_taken;
    reg [31:0]   	actual_target;
	reg [31:0]		branch_rs;
	reg [31:0]		branch_rt;
	reg [31:0] 		ID_EX_wr_addr;
	reg 			IF_ID_predicted_taken; //이전에 예측했던 값 이용
	reg				is_internal_forwarding_rs; //internal forwarding을 위해
	reg				is_internal_forwarding_rt;
	reg     		prev_hazard;

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



	always @(*) begin
		//WB할 값 결정
		wr_data = (MEM_WB_MemtoReg) ? MEM_WB_mem_read_data : MEM_WB_alu_result;
		if(MEM_WB_SavePC) begin
			wr_addr = 5'd31;
			wr_data = MEM_WB_PC + 4;
		end else begin
			wr_addr = MEM_WB_wr_addr;
		end

		//EX를 위해 operand1,2 값 구하기 + FORWARDING
		operand1 = 0;
		operand2 = 0;
		operand1 = (ForwardA == 2) ? EX_MEM_alu_result :
		            (ForwardA == 1) ? wr_data :
		                            ID_EX_rd_data1;

		operand2 = (ID_EX_ALUSrc) ? ID_EX_ext_imm :
		            (ForwardB == 2) ? EX_MEM_alu_result :
		            (ForwardB == 1) ? wr_data :
		                            ID_EX_rd_data2;

		//MEM단계에 넣을 latch값을 Forwarding이용해서 업데이트하기
		Forwarded_rd_data2 = (ForwardB == 2) ? EX_MEM_alu_result :
	                        (ForwardB == 1) ? wr_data :
	                                		ID_EX_rd_data2;



		// //WB -> RF internal forwarding. 근데 덮어쓰는게 가능하던가 베릴로그가;;
		// if (MEM_WB_RegWrite && MEM_WB_wr_addr != 0) { 	// Internal Forwarding: WB에서 쓰려는 값이랑 겹치면 override
		//     if (MEM_WB_wr_addr == IF_ID_rs) {
		//         rd_data1 = wr_data;
		//     }
		//     if (MEM_WB_wr_addr == IF_ID_rt) {
		//         rd_data2 = wr_data;
		//     }
		// } //흠 코드가 좀 중복되나 싶기도 하고? 맞는거같은데.. 어차피 Branch Resolution할 때에만 쓰는 듯
		//   //아 아닌가? JR에서 PC값 계산에 쓰는거같긴한데..
		// 아 이거 clock 튈때, 이 조건 보고 덮어줘야할 것 같은데???
		is_internal_forwarding_rs = 0;
		is_internal_forwarding_rt = 0;
		if(MEM_WB_RegWrite && MEM_WB_wr_addr != 0) begin
			if(MEM_WB_wr_addr == IF_ID_rs) is_internal_forwarding_rs = 1;
			if(MEM_WB_wr_addr == IF_ID_rt) is_internal_forwarding_rt = 1;
		end


		//Branch ID단계에서 계산.
		branch_rs = rd_data1;
		branch_rt = rd_data2;
		actually_taken = 1;
		actual_target = 0;

		// Forward from MEM/WB
		if (MEM_WB_RegWrite && MEM_WB_wr_addr != 0) begin
		    if (MEM_WB_wr_addr == IF_ID_rs) branch_rs = wr_data;
		    if (MEM_WB_wr_addr == IF_ID_rt) branch_rt = wr_data;
		end

		// Forward from EX/MEM
		if (EX_MEM_RegWrite && EX_MEM_wr_addr != 0) begin
		    if (EX_MEM_wr_addr == IF_ID_rs) branch_rs = EX_MEM_alu_result;
		    if (EX_MEM_wr_addr == IF_ID_rt) branch_rt = EX_MEM_alu_result;
		end

		// Forward from ID/EX (최신 연산 결과가 바로 뒤 cycle일 때도 고려)
		ID_EX_wr_addr = (ID_EX_RegDst) ? ID_EX_rd : ID_EX_rt;
		if (ID_EX_RegWrite && ID_EX_wr_addr != 0) begin
		    if (ID_EX_wr_addr == IF_ID_rs) branch_rs = alu_result; // 필요 시 ALU result 저장해야 함
		    if (ID_EX_wr_addr == IF_ID_rt) branch_rt = alu_result;
		end

		if(JR) begin
			PC_next_for_JR = rd_data1; //PC_next_for_JR는 JR전용이야 이제..
		end else if(Branch && ALUOp == `ALU_EQ && branch_rs == branch_rt) begin
			actual_target = IF_ID_PC + 4 + (ext_imm << 2);
		end	else if(Branch && ALUOp == `ALU_NEQ && branch_rs != branch_rt) begin
		 	actual_target = IF_ID_PC + 4 + (ext_imm << 2);
		end else if(Jump) begin
			actual_target = {IF_ID_PC[31:28], (IF_ID_immj << 2)};
		end else begin
			actually_taken = 0;
			actual_target = PC + 4;
		end

		mispredict = 0;
		if(IF_ID_instruction != 32'b0 && !JR) begin
			if (IF_ID_predicted_taken != actually_taken) begin // PHT가 잘 동작했는지. T/NT
			    mispredict = 1;
			end else if (IF_ID_predicted_taken && IF_ID_PC != actual_target) begin // T이라면, BTB가 잘 동작했는지. (= 이전에 fetch.. 잘 한거 맞나요? 를 체크하는거임.)
			    mispredict = 1;
			end
		end

	end

	// Update the Clock
	always @(posedge clk) begin
		// $display("PC: %h, inst: %h", PC, inst);
		// $display("IF_ID_PC: %h, IF_ID_instruction: %h", IF_ID_PC, IF_ID_instruction);
		// $display("IF_ID_rs: %d, IF_ID_rt: %d", IF_ID_rs, IF_ID_rt);
		// $display("ID_EX_PC: %h, ID_EX_RegWrite: %d, ID_EX_rd: %d, ID_EX_rt: %d",ID_EX_PC, ID_EX_RegWrite, ID_EX_rd, ID_EX_rt);
		// $display("ForwardA :%d, ForwardB: %d", ForwardA, ForwardB);
		// $display("operand1: %h, EX_MEM_alu_result: %h, wr_data: %h, ID_EX_rd_data1: %h", operand1, EX_MEM_alu_result, wr_data, ID_EX_rd_data1);
		// $display("operand2: %h, EX_MEM_alu_result: %h, wr_data: %h, ID_EX_rd_data2: %h", operand2, EX_MEM_alu_result, wr_data, ID_EX_rd_data2);
		// $display("EX_MEM_PC: %h, EX_MEM_RegWrite: %d, EX_MEM_wr_addr: %d", EX_MEM_PC, EX_MEM_RegWrite, EX_MEM_wr_addr);
		// $display("MEM_WB_PC: %h, MEM_WB_RegWrite: %d, MEM_WB_wr_addr: %d, MEM_WB_wr_data: %h",MEM_WB_PC, MEM_WB_RegWrite, MEM_WB_wr_addr, wr_data);
		// $display("Hazard_stall: %d", hazard_stall);
		// $display("misprediction: %d", mispredict);
		// $display("=========================");
		if (rst) begin
			PC <= 32'b0;
			mispredict <= 0;
			delay_cycles <= 3'b110; //6으로 설정해두고, delay_cycles가 0이 되면 halt 신호를 1로 설정
									//halt는 delay_cycle 값 바뀌면 바로 업데이트 되어서.. 3'b111로 설정해야 할 수도? {의심}
			//모든 latch 초기화 필요!!!
			IF_ID_PC <= 32'b0;
			IF_ID_instruction <= 32'b0;
			ID_EX_PC <= 32'b0;
			ID_EX_rd_data1 <= 32'b0;
			ID_EX_rd_data2 <= 32'b0;
			ID_EX_ext_imm <= 32'b0;
			ID_EX_rs <= 5'b0;
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
			IF_ID_predicted_taken <= 1'b0;
			prev_hazard <= 0;
		end else begin
			//Update Latches
			// IF/ID & ID/EX << hazard나 misprediction때문에 같이 처리.
			if(mispredict) begin //misprediction 발생 O
				// if(SavePC) begin //이전이랑 다르게 생각해보니까, Branch resolution하는애는 무조건 정상인 값이잖아
					//원랜 여기서만 해줬었는데.. 굳이 그럴 필요가 없쟈낭
				// end else begin
				// 	// ID_EX_PC <= 0;
				// 	ID_EX_PC <= IF_ID_PC; //PC는 넘겨줘도 되는거 아닌가?
				// 	ID_EX_rd_data1 <= 0;
				// 	ID_EX_rd_data2 <= 0;
				// 	ID_EX_ext_imm <= 0;
				// 	ID_EX_rs <= 0;
				// 	ID_EX_rt <= 0;
				// 	ID_EX_rd <= 0;
				// 	ID_EX_shamt <= 0;
				// 	ID_EX_RegDst <= 0;
				// 	ID_EX_ALUSrc <= 0;
				// 	ID_EX_ALUOp <= 0;
				// 	ID_EX_MemtoReg <= 0;
				// 	ID_EX_MemRead <= 0;
				// 	ID_EX_MemWrite <= 0;
				// 	ID_EX_RegWrite <= 0;
				// 	ID_EX_immj <= 0;
				// 	ID_EX_Branch <= 0;
				// 	ID_EX_Jump <= 0;
				// 	ID_EX_JR <= 0;
				// 	ID_EX_SavePC <= 0;
				// end
				ID_EX_PC <= IF_ID_PC;
				ID_EX_rd_data1 <= (is_internal_forwarding_rs) ? wr_data : rd_data1;
				ID_EX_rd_data2 <= (is_internal_forwarding_rt) ? wr_data : rd_data2;
				ID_EX_ext_imm <= ext_imm;
				ID_EX_rs <= IF_ID_rs;
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
				IF_ID_PC <= 0;
        		IF_ID_instruction <= 0;
				PC = actual_target; //올바른 PC로 되돌림'
				mispredict <= 0;
			end else begin	//misprediction 발생 X
				if(hazard_stall > 0 || prev_hazard > 0) begin
					PC <= PC;
					IF_ID_PC <= IF_ID_PC;
					IF_ID_instruction <= IF_ID_instruction;	
				end else if (JR) begin
					PC <= PC_next_for_JR;
					IF_ID_PC <= 32'b0;
					IF_ID_instruction <= 32'b0;		    
				end else begin
					PC <= nextPC;
        			IF_ID_PC <= PC;
        			IF_ID_instruction <= inst;
					IF_ID_predicted_taken <= predict_taken;
				end	//여기까지가, PC, IF_ID 이렇게 둘

				if (hazard_stall > 0 || prev_hazard > 0) begin 
					ID_EX_PC <= 0;
					ID_EX_rd_data1 <= 0;
					ID_EX_rd_data2 <= 0;
					ID_EX_ext_imm <= 0;
					ID_EX_rs <= 0;
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
					if(hazard_stall == 2) prev_hazard <= 1;
					if(prev_hazard == 1) prev_hazard <= 0;
				end else begin //hazard만 아니면 제대로 들어가는거 맞는데
					ID_EX_PC <= IF_ID_PC;
					ID_EX_rd_data1 <= (is_internal_forwarding_rs) ? wr_data : rd_data1;
					ID_EX_rd_data2 <= (is_internal_forwarding_rt) ? wr_data : rd_data2;
					ID_EX_ext_imm <= ext_imm;
					ID_EX_rs <= IF_ID_rs;
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
			end

        	// EX/MEM
			EX_MEM_PC <= ID_EX_PC;
			EX_MEM_alu_result <= alu_result;
			EX_MEM_rd_data2 <= Forwarded_rd_data2;
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
			// $display("EX_MEM -> mem_write_data: %h, EX_MEM_MemWrite: %d", EX_MEM_rd_data2, EX_MEM_MemWrite);

			//종료 조건
			if (inst == 32'b0 || delay_cycles != 3'b110) begin //종료 조건이 시작되었다면..
				if (hazard_stall == 0 && mispredict == 0)
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
	HAZARD hazard (
	    .opcode(IF_ID_opcode),
	    .funct(IF_ID_funct),
	    .rs(IF_ID_rs),
	    .rt(IF_ID_rt),
	    .id_ex_rt(ID_EX_rt),
	    .id_ex_MemRead(ID_EX_MemRead),
	    .hazard_stall(hazard_stall)
	);
	BP bp (
	    .clk(clk),
	    .rst(rst),
	    .PC(PC),
	    .predict_taken(predict_taken),
	    .nextPC(nextPC), //여기까지가 predict()에 해당
	    .update_en((!JR && (Branch || Jump))), //여기서부터 update()에 해당
	    .update_pc(IF_ID_PC),
	    .update_taken(actually_taken),
	    .update_target(actual_target),
	    .update_is_branch(Branch)
	);
	FORWARDING fw (
	    .id_ex_rs(ID_EX_rs),
	    .id_ex_rt(ID_EX_rt),
	    .ex_mem_wr_addr(EX_MEM_wr_addr),
	    .ex_mem_RegWrite(EX_MEM_RegWrite),
	    .mem_wb_wr_addr(MEM_WB_wr_addr),
	    .mem_wb_RegWrite(MEM_WB_RegWrite),
	    .ForwardA(ForwardA),
	    .ForwardB(ForwardB)
	);
	
endmodule

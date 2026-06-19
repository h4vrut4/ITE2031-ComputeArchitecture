// BP.v
`timescale 1ns / 1ps

module BP(
    input           clk,
    input           rst,

    // 예측 요청 (항상 동작)
    input  [31:0]   PC,
    output reg      predict_taken,
    output reg [31:0] nextPC,

    // 예측 결과 업데이트
    input           update_en,
    input  [31:0]   update_pc,
    input           update_taken,
    input  [31:0]   update_target,
    input           update_is_branch
);
    // ----- Parameter 정의 -----
    localparam BTB_SIZE = 64;
    localparam PHT_SIZE = 256;

    localparam BTB_EMPTY  = 2'd0;
    localparam BTB_JUMP   = 2'd1;
    localparam BTB_BRANCH = 2'd2;

    localparam STRONGLY_NOT_TAKEN = 2'd0;
    localparam WEAKLY_NOT_TAKEN   = 2'd1;
    localparam WEAKLY_TAKEN       = 2'd2;
    localparam STRONGLY_TAKEN     = 2'd3;

    // ----- BTB, PHT 메모리 -----
    reg [1:0]  btb_state   [0:BTB_SIZE-1];
    reg [23:0] btb_tag     [0:BTB_SIZE-1];
    reg [31:0] btb_target  [0:BTB_SIZE-1];

    reg [1:0]  pht         [0:PHT_SIZE-1];

    // ----- Index & Tag 추출 -----
    wire [5:0]  btb_index = PC[7:2];
    wire [7:0]  pht_index = PC[9:2];
    wire [23:0] pc_tag    = PC[31:8];

    wire [5:0]  update_btb_index = update_pc[7:2];
    wire [7:0]  update_pht_index = update_pc[9:2];
    wire [23:0] update_tag       = update_pc[31:8];

    // ----- 예측 로직 -----
    always @(*) begin
        if (btb_state[btb_index] == BTB_EMPTY || btb_tag[btb_index] != pc_tag) begin
            predict_taken = 0;
            nextPC = PC + 4;
        end else if (btb_state[btb_index] == BTB_JUMP) begin
            predict_taken = 1;
            nextPC = btb_target[btb_index];
        end else if (btb_state[btb_index] == BTB_BRANCH) begin
            if (pht[pht_index] >= WEAKLY_TAKEN) begin
                predict_taken = 1;
                nextPC = btb_target[btb_index];
            end else begin
                predict_taken = 0;
                nextPC = PC + 4;
            end
        end else begin
            predict_taken = 0;
            nextPC = PC + 4;
        end
    end
    
    integer i;
    // ----- 업데이트 로직 -----
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < BTB_SIZE; i = i + 1) begin
                btb_state[i]  <= BTB_EMPTY;
                btb_tag[i]    <= 24'b0;
                btb_target[i] <= 32'b0;
            end
            for (i = 0; i < PHT_SIZE; i = i + 1) begin
                pht[i] <= WEAKLY_NOT_TAKEN;
            end
        end else if (update_en) begin //update_en으로는 !controls.JR && (controls.Branch || controls.Jump) => 베릴로그 식으론, !JR && (Branch || Jump) 이거네
            btb_state[update_btb_index]  <= update_is_branch ? BTB_BRANCH : BTB_JUMP;
            btb_tag[update_btb_index]    <= update_tag;
            btb_target[update_btb_index] <= update_target;

            if (update_is_branch) begin
                case (pht[update_pht_index])
                    STRONGLY_NOT_TAKEN: pht[update_pht_index] <= update_taken ? WEAKLY_NOT_TAKEN : STRONGLY_NOT_TAKEN;
                    WEAKLY_NOT_TAKEN:   pht[update_pht_index] <= update_taken ? WEAKLY_TAKEN     : STRONGLY_NOT_TAKEN;
                    WEAKLY_TAKEN:       pht[update_pht_index] <= update_taken ? STRONGLY_TAKEN   : WEAKLY_NOT_TAKEN;
                    STRONGLY_TAKEN:     pht[update_pht_index] <= update_taken ? STRONGLY_TAKEN   : WEAKLY_TAKEN;
                endcase
            end
        end
    end
endmodule

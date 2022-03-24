module midprocess_ZF(
    input enable, clk, reset_n, accept_in,
    output accept_out, ready_out,
//
    input [31:0] Q_processed_2, //2 phần tử hàng 2 của Q_processed
    input [31:0] R, //2 phần tử bên phải hàng 2 của R
    input [31:0] X_pre, //2 phần tử hàng cuối (đã tính được của X)
    output [31:0] X_mid_pre
);

midprocess_ZF_controller controller(enable, clk, reset_n, accept_in, accept_out, ready_out, mul_cal_row2_1, mul_cal_row2_2, sub_2);

midprocess_ZF_datapath datapath(clk, reset_n, Q_processed_2, R, X_pre, X_mid_pre, mul_cal_row2_1, mul_cal_row2_2, sub_2);


endmodule

module midprocess_ZF_controller (
    input enable, clk, reset_n, accept_in,
    output accept_out, 
    output reg ready_out,

//control
    output mul_cal_row2_1, mul_cal_row2_2, sub_2
);


localparam  IDLE            = 0,
            MUL_CAL_ROW2_1  = 1, 
            MUL_CAL_ROW2_2  = 2,
            SUB_2           = 3,
            READY           = 4;

reg [2:0] current_state, next_state;
//output
assign accept_out   = (current_state == IDLE);

//control
assign mul_cal_row2_1 = (current_state == MUL_CAL_ROW2_1);
assign mul_cal_row2_2 = (current_state == MUL_CAL_ROW2_2);
assign sub_2= (current_state == SUB_2);
//fsm
always @(*) begin
    case(current_state)
    IDLE: next_state = enable ? MUL_CAL_ROW2_1 : IDLE;
    MUL_CAL_ROW2_1: next_state = MUL_CAL_ROW2_2;
    MUL_CAL_ROW2_2: next_state = SUB_2;
    SUB_2: next_state = READY;
    READY: next_state = accept_in ? IDLE : READY;

    default: next_state = IDLE; 
    endcase
end
always @(posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        current_state <= IDLE;
        ready_out    <= 0;
    end
    else begin
        current_state <= next_state;
        ready_out    <= (current_state == READY);
    end
end
    
endmodule

module midprocess_ZF_datapath(
    input clk, reset_n,
    input [31:0] Q_processed_2, //2 phần tử hàng 2 của Q_processed
    input [31:0] R, //2 phần tử bên phải hàng 2 của R
    input [31:0] X_pre, //2 phần tử hàng cuối (đã tính được của X)
    output reg [31:0] X_mid_pre,
//control
    input mul_cal_row2_1, mul_cal_row2_2, sub_2
);
////////////////////////////////////////////////
wire [15:0] sub_res_1, sub_res_2;
reg [15:0] sub_in1_1, sub_in1_2, sub_in2_1, sub_in2_2;

adder subtracter1(sub_res_1, sub_in1_1, {(1'b1^sub_in1_2[15]),sub_in1_2[14:0]});
adder subtracter2(sub_res_2, sub_in2_1, {(1'b1^sub_in2_2[15]),sub_in2_2[14:0]});
////////////////////////////////////////////////////////////
wire [15:0] mul_res_1, mul_res_2;
reg [15:0] mul_in1_1, mul_in1_2, mul_in2_1, mul_in2_2;

mul mul1(mul_res_1, mul_in1_1, mul_in1_2);
mul mul2(mul_res_2, mul_in2_1, mul_in2_2);
//////////////////////////////////////
always @(posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        sub_in1_1 <= 0;
        sub_in1_2 <= 0;
        sub_in2_1 <= 0;
        sub_in2_2 <= 0;
        X_mid_pre <= 0;
        mul_in1_1 <= 0;
        mul_in1_2 <= 0;
        mul_in2_1 <= 0;
        mul_in2_2 <= 0;
    end
    else begin
        if(mul_cal_row2_1) begin
            mul_in1_1 <= R[15:0];
            mul_in1_2 <= X_pre[31:16];

            mul_in2_1 <= R[15:0];
            mul_in2_2 <= X_pre[15:0];
        end
        if(mul_cal_row2_2) begin
            mul_in1_1 <= R[31:16];
            mul_in1_2 <= X_pre[15:0];
            sub_in1_1 <= Q_processed_2[31:16];
            sub_in1_2 <= mul_res_1;

            mul_in2_1 <= R[31:16];
            mul_in2_2 <= {1'b1 ^ X_pre[31], X_pre[30:16]};
            sub_in2_1 <= Q_processed_2[15:0];
            sub_in2_2 <= mul_res_2;
        end
        if(sub_2) begin
            sub_in1_1 <= sub_res_1;
            sub_in1_2 <= mul_res_1;

            sub_in2_1 <= sub_res_2;
            sub_in2_2 <= mul_res_2;
        end
        X_mid_pre <= {sub_res_1, sub_res_2};
    end
end


endmodule

// module tb_midprocess_ZF;
//     reg enable, clk, reset_n, accept_in;
//     wire accept_out, ready_out;
// //
//     reg [31:0] Q_processed_2; //2 phần tử hàng 2 của Q_processed
//     reg [31:0] R; //2 phần tử bên phải hàng 2 của R
//     reg [31:0] X_pre; //2 phần tử hàng cuối (đã tính được của X)
//     wire [31:0] X_mid_pre; // ma trận X

// midprocess_ZF uut(enable, clk, reset_n, accept_in, accept_out, ready_out, Q_processed_2, R, X_pre, X_mid_pre);

// initial begin
//     clk = 0;
//     forever #5 clk = ~clk;
// end
// initial begin
//     reset_n = 0; @(negedge clk);
//     reset_n = 1;
// end
// initial begin
//     enable = 1;
//     accept_in = 1;
// end

// initial begin
//     Q_processed_2 = 32'b00110011001100110001110011001100;
//     R = 32'b00001001100110010000011001100110;
//     X_pre = 32'b00000110011001100000111001100110;
// end



// endmodule

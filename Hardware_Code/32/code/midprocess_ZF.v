module midprocess_ZF(
    input enable, clk, reset_n, accept_in,
    output accept_out, ready_out,
//
    input [63:0] Q_processed_2, //2 phần tử hàng 2 của Q_processed
    input [63:0] R, //2 phần tử bên phải hàng 2 của R
    input [63:0] X_pre, //2 phần tử hàng cuối (đã tính được của X)
    output [63:0] X_mid_pre
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
// assign ready_out    = (current_state == READY);

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
    input [63:0] Q_processed_2, //2 phần tử hàng 2 của Q_processed
    input [63:0] R, //2 phần tử bên phải hàng 2 của R
    input [63:0] X_pre, //2 phần tử hàng cuối (đã tính được của X)
    output reg [63:0] X_mid_pre,
//control
    input mul_cal_row2_1, mul_cal_row2_2, sub_2
);
////////////////////////////////////////////////
wire [31:0] sub_res_1, sub_res_2;
reg [31:0] sub_in1_1, sub_in1_2, sub_in2_1, sub_in2_2;

adder subtracter1(sub_res_1, sub_in1_1, {(1'b1^sub_in1_2[31]),sub_in1_2[30:0]});
adder subtracter2(sub_res_2, sub_in2_1, {(1'b1^sub_in2_2[31]),sub_in2_2[30:0]});
////////////////////////////////////////////////////////////
wire [31:0] mul_res_1, mul_res_2;
reg [31:0] mul_in1_1, mul_in1_2, mul_in2_1, mul_in2_2;

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
            mul_in1_1 <= R[31:0];
            mul_in1_2 <= X_pre[63:32];

            mul_in2_1 <= R[31:0];
            mul_in2_2 <= X_pre[31:0];
        end
        if(mul_cal_row2_2) begin
            mul_in1_1 <= R[63:32];
            mul_in1_2 <= X_pre[31:0];
            sub_in1_1 <= Q_processed_2[63:32];
            sub_in1_2 <= mul_res_1;

            mul_in2_1 <= R[63:32];
            mul_in2_2 <= {1'b1 ^ X_pre[63], X_pre[62:32]};
            sub_in2_1 <= Q_processed_2[31:0];
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

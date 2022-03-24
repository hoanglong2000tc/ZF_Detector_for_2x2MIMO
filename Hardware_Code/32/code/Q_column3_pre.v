module Q_column3_pre(
    input  enable, clk, reset_n, accept_in,
    output accept_out, ready_out,
//
    input [127:0] H_col3, Q_col1, Q_col2,
    output [127:0] Q_col3_pre
);

Q_column3_pre_controller controller(
    enable, clk, reset_n, accept_in,
    accept_out, ready_out,
//control
    cal_proj_done,
    cal_proj, sub, end_sub
);

Q_column3_pre_datapath datapath(
    clk, reset_n,

    H_col3, Q_col1, Q_col2,
    Q_col3_pre,
//control
    cal_proj, sub, end_sub,
    cal_proj_done
);

endmodule

module Q_column3_pre_controller(
    input enable, clk, reset_n, accept_in,
    output accept_out, 
    output reg ready_out,
//control
    input cal_proj_done,
    output cal_proj, sub, end_sub
);
localparam  IDLE            = 0,
            CAL_PROJ        = 1,
            SUBTRACT        = 2,
            END_SUBTRACT    = 3,
            WAIT            = 4,
            READY           = 5;

reg [2:0] current_state, next_state;
//output
assign accept_out   = (current_state == IDLE);

//control
assign cal_proj = (current_state == CAL_PROJ);
assign sub = (current_state == SUBTRACT);
assign end_sub = (current_state == END_SUBTRACT);
//fsm
always @(*) begin
    case(current_state)
    IDLE: next_state = enable ? CAL_PROJ : IDLE;
    CAL_PROJ: next_state = WAIT;
    SUBTRACT: next_state = END_SUBTRACT;
    END_SUBTRACT: next_state = READY;
    WAIT: next_state = cal_proj_done ? SUBTRACT : WAIT;
    READY: next_state = accept_in ? IDLE : READY;
    default: next_state = IDLE;
    endcase
end
always @(posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        current_state <= IDLE;
        ready_out <=0;
    end
    else begin
        current_state <= next_state;
        ready_out    <= (current_state == READY);
    end
end


endmodule

module Q_column3_pre_datapath(
    input clk, reset_n,

    input [127:0] H_col3, Q_col1, Q_col2,
    output reg [127:0] Q_col3_pre,
//control
    input cal_proj, sub, end_sub,
    output cal_proj_done
);

wire [1:0] cal_proj_done_wire;
assign cal_proj_done = (cal_proj_done_wire == 2'b11);

wire [127:0] proj_res1, proj_res2, sub_res;
proj projection1(proj_res1, Q_col1, H_col3, clk, reset_n, cal_proj, cal_proj_done_wire[0]);
proj projection2(proj_res2, Q_col2, H_col3, clk, reset_n, cal_proj, cal_proj_done_wire[1]);

reg [127:0] sub_in1, sub_in2;
matrix_4x1_subtracter matrix_4x1_subtracter(sub_in1, sub_in2, sub_res);


always @(posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        sub_in1 <= 0;
        sub_in2 <= 0;
        Q_col3_pre <= 0;
    end
    else begin
        if(sub) begin
            sub_in1 <= H_col3;
            sub_in2 <= proj_res1;
        end
        if(end_sub) begin
            sub_in1 <= sub_res;
            sub_in2 <= proj_res2;
        end
        Q_col3_pre <= sub_res;
    end
end


endmodule



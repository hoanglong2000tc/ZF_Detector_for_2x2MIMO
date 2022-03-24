module norm2(
    input [127:0] vector,
    input enable, clk, reset_n, accept_in,
    output accept_out, ready_out,
    output [31:0] res
);


norm2_controller controller(enable, clk, reset_n, accept_in, accept_out, ready_out, valid, add, end_add, square);
norm2_datapath datapath(vector, clk, reset_n, res, add, end_add, square, valid);

endmodule

module norm2_controller(
    input enable, clk, reset_n, accept_in,
    output accept_out, ready_out,
//control
    input valid,
    output add, end_add, square
);
localparam  IDLE        = 0,
            MUL         = 1,
            ADD         = 2,
            END_ADD     = 3,
            SQUARE      = 4,
            READY       = 5;

reg [2:0] current_state, next_state;
//output
assign accept_out   = (current_state == IDLE);
assign ready_out    = (current_state == READY);

//control
assign add = (current_state == ADD);
assign square = (current_state == SQUARE);
assign end_add = (current_state == END_ADD);
//fsm
always @(*) begin
    case(current_state)
    IDLE: next_state = enable ? MUL : IDLE;
    MUL: next_state = ADD;
    ADD : next_state = END_ADD;
    END_ADD: next_state = SQUARE;
    SQUARE: begin
        if(valid) next_state = READY;
        else next_state = SQUARE;
    end
    READY: next_state = accept_in ? IDLE : READY;

    default: next_state = IDLE; 
    endcase
end
always @(posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end
endmodule

module norm2_datapath(
    input [127:0] vector,
    input clk, reset_n,
    output [31:0] res,
//control
    input add, end_add, square,
    output valid
);
wire [31:0] add_res1, add_res2, mul_res_1, mul_res_2, mul_res_3, mul_res_4;
reg [31:0] add1_1, add1_2, add2_1, add2_2;


mul m1(mul_res_1, vector[127:96], vector[127:96]);
mul m2(mul_res_2, vector[95:64], vector[95:64]);
mul m3(mul_res_3, vector[63:32], vector[63:32]);
mul m4(mul_res_4, vector[31:0], vector[31:0]);

adder a1(add_res1, add1_1, add1_2);
adder a2(add_res2, add2_1, add2_2);

always @(posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        add1_1 <= 0;
        add1_2 <= 0;
        add2_1 <= 0;
        add2_2 <= 0;
    end
    else begin
        if(add) begin
            add1_1 <= mul_res_1;
            add1_2 <= mul_res_2;
            add2_1 <= mul_res_3;
            add2_2 <= mul_res_4;
        end
        if(end_add) begin
            add1_1 <= add_res1;
            add1_2 <= add_res2;
        end
    end
end

square_root s1(.clk(clk), .reset_n(reset_n), .start(square), .rad(add_res1), .root(res), .done(valid));

endmodule
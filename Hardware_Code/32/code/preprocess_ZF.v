module preprocess_ZF(
    input enable, clk, reset_n, accept_in,
    output accept_out, ready_out,
//
    input [255:0] y, n,
    input [511:0] invQ,
    output [255:0] Q_processed
);

preprocess_ZF_controller controller(enable, clk, reset_n, accept_in, accept_out, ready_out, mul_done, mul, subtract);

preprocess_ZF_datapath datapath(clk, reset_n, y, n, invQ, Q_processed, mul, subtract, mul_done);


endmodule

module preprocess_ZF_controller (
    input enable, clk, reset_n, accept_in,
    output accept_out, ready_out,

//control
    input mul_done,
    output mul, subtract
);

localparam  IDLE        = 0,
            MUL         = 1,
            SUBTRACT    = 2,
            WAIT        = 3,
            READY       = 4;

reg [2:0] current_state, next_state;
//output
assign accept_out   = (current_state == IDLE);
assign ready_out    = (current_state == READY);

//control
assign mul = (current_state == MUL);
assign subtract = (current_state == SUBTRACT);
//fsm
always @(*) begin
    case(current_state)
    IDLE: next_state = enable ? MUL : IDLE;
    MUL: next_state = WAIT;
    SUBTRACT: next_state = READY;
    WAIT: next_state = mul_done ? SUBTRACT : WAIT;
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

module preprocess_ZF_datapath(
    input clk, reset_n,
    input [255:0] y, n,
    input [511:0] invQ,
    output [255:0] Q_processed,
//control
    input mul, subtract,
    output mul_done
    
);

wire [1:0] done_mul_matrix;
wire [255:0] inv_Q_and_y, inv_Q_and_n;
assign mul_done = (done_mul_matrix == 2'b11);
mul_4x4_4x2 mulMatrix1(clk, reset_n, mul, invQ, y, done_mul_matrix[0], inv_Q_and_y);
mul_4x4_4x2 mulMatrix2(clk, reset_n, mul, invQ, n, done_mul_matrix[1], inv_Q_and_n);

reg [127:0] A1, B1, A2, B2;
matrix_4x1_subtracter matrix_4x1_subtracter1(A1, B1, Q_processed[255:128]);
matrix_4x1_subtracter matrix_4x1_subtracter2(A2, B2, Q_processed[127:0]);
always @(posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        A1 <= 0;
        B1 <= 0;
        A2 <= 0;
        B2 <= 0;
    end
    else begin
        if(subtract) begin
            A1 <= inv_Q_and_y[255:128];
            B1 <= inv_Q_and_n[255:128];
            A2 <= inv_Q_and_y[127:0];
            B2 <= inv_Q_and_n[127:0];
        end
    end
end


endmodule
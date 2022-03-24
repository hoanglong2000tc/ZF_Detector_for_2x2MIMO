module non_restoring_divider #(
    parameter N = 8
) (
    input enable, clk, reset_n, accept_in,
    output accept_out, ready_out,
//
    input [N-1:0] divisor, dividend,
    output [N-1:0] quotient
);


non_restoring_divider_controller controller(
    enable, clk, reset_n, accept_in,
    accept_out, set_ready_out,
//control
    sign_A, count_done,
    dec_count, substract_and_shift, add_and_shift, initial_data
);

non_restoring_divider_datapath #(.N(N)) datapth(
    clk, reset_n, set_ready_out,
    dividend, divisor, quotient, ready_out,
//control
    dec_count, substract_and_shift, add_and_shift, initial_data,
    sign_A, count_done
);
    
endmodule

module non_restoring_divider_controller(
    input enable, clk, reset_n, accept_in,
    output accept_out, 
    output reg set_ready_out,
//control
    input sign_A, count_done,
    output reg dec_count, substract_and_shift, add_and_shift, initial_data
);

localparam  IDLE        = 0,
            GET_DATA    = 1,
            COMPUTE     = 2,
            READY       = 3;

reg [1:0] current_state, next_state;
//output
assign accept_out   = (current_state == IDLE) & enable;
//fsm
always @(*) begin
    dec_count           = 0;
    substract_and_shift = 0;
    add_and_shift       = 0;
    initial_data        = 0;
    set_ready_out = 0;
    /////////////////////////
    case(current_state)
    IDLE: next_state = enable ? GET_DATA : IDLE;
    GET_DATA: begin
        initial_data = 1;
        next_state = COMPUTE;
    end
    COMPUTE: begin
        if(sign_A) add_and_shift = 1;
        else substract_and_shift = 1;
        if(count_done) begin
            set_ready_out = 1;
            next_state = accept_in ? IDLE : READY;
        end
        else next_state = COMPUTE;
        dec_count = 1;
    end
    READY: next_state = accept_in ? IDLE : READY;
    default: next_state = IDLE;
    endcase
end

always @(posedge clk, negedge reset_n) begin
    if(~reset_n) current_state <= IDLE;
    else current_state <= next_state;
end


endmodule

module non_restoring_divider_datapath #(
    parameter N = 8
) (
    input clk, reset_n, set_ready_out,
    input [N-1:0] dividend, divisor,
    output [N-1:0] quotient,
    output reg ready_out,
//control
    input dec_count, substract_and_shift, add_and_shift, initial_data,
    output sign_A, count_done
);

reg [N-1:0] Q;
reg [N:0] A, M;
reg [$clog2(N):0] count;
assign count_done = (count == 0);
assign sign_A = A[N];
assign quotient = Q;
// assign remainder = A;


wire [N:0] A_minus_M, A_plus_M;
assign A_minus_M = {A[N-1:0], Q[N-1]} - M;
assign A_plus_M = {A[N-1:0], Q[N-1]} + M;

//Khối GET_DATA
always @(posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        A <= 0;
        M <= 0;
        Q <= 0;
        ready_out <= 0;
    end
    else begin
        ready_out <= set_ready_out;
        A <= A;
        M <= M;
        Q <= Q;
        if(initial_data) begin
            A <= {(N+1){1'b0}};
            M <= {1'b0, divisor};
            Q <= dividend;
        end
        else if(add_and_shift) begin
            A <= {A[N-1:0], Q[N-1]} + M;
            Q <= {Q[N-2:0], ~A_plus_M[N]};
        end
        else if(substract_and_shift) begin
            A <= {A[N-1:0], Q[N-1]} - M;
            Q <= {Q[N-2:0], ~A_minus_M[N]};
        end
        else begin
            A <= A;
            M <= M;
            Q <= Q;
        end
    end
end


//Khối count
always @(posedge clk, negedge reset_n) begin
    if(~reset_n) count <= N - 1;
    else if(initial_data) count <= N - 1;
    else if(dec_count) count <= count - 1'b1;
    else count <= count;
end


endmodule
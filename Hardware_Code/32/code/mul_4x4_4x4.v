module mul_4x4_4x4(
    input enable, clk, reset_n, accept_in,
    output accept_out, ready_out,
    //
    input [511:0] A, 
    input [511:0] B,
    output [511:0] result
);
wire  mul, add, end_add;
mul_4x4_4x4_controller controller(
    enable, clk, reset_n, accept_in, accept_out, ready_out, mul, add, end_add
);


mul_4x4_4x4_datapath datapath(
    clk, reset_n, A, B, result, mul, add, end_add
);


endmodule



module mul_4x4_4x4_controller(
    input enable, clk, reset_n, accept_in,
    output accept_out, 
    output ready_out,
//control
    output mul, add, end_add
);

localparam  IDLE        = 0,
            MUL         = 1,
            ADD         = 2,
            END_ADD     = 3,
            READY       = 4;

reg [2:0] current_state, next_state;
//output
assign accept_out   = (current_state == IDLE);
assign ready_out    = (current_state == READY);

//control
assign mul = (current_state == MUL);
assign add = (current_state == ADD);
assign end_add = (current_state == END_ADD);

//fsm
always @(*) begin
    case(current_state)
    IDLE: next_state = enable ? MUL : IDLE;
    MUL: next_state = ADD;
    ADD: next_state = END_ADD;
    END_ADD: next_state = READY;
    READY: next_state = accept_in ? IDLE : READY;
    default: next_state = IDLE;
    endcase
end

always @(posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        current_state <= IDLE;
        // ready_out    <= 0;
    end
    else begin
        current_state <= next_state;
        // ready_out    <= (current_state == READY);
    end
end


endmodule

module mul_4x4_4x4_datapath(
    input clk, reset_n,
    input [511:0] A, 
    input [511:0] B,
    output reg [511:0] result,
//control
    input mul, add, end_add

);

wire [31:0] temp[0:63];
reg [31:0] temp_reg[0:63];
wire [31:0] add_temp[0:31];
reg [31:0] add_temp_reg[0:31];
wire [511:0] result_wire;
integer index;

always @(posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        for(index = 0; index <= 63; index = index + 1) begin
            temp_reg[index] <= 0;
        end
        for(index = 0; index <= 31; index = index + 1) begin
            add_temp_reg[index] <= 0;
        end
        result <= 0;
    end
    else begin
        if(mul) begin
            for(index = 0; index <= 63; index = index + 1) begin
                temp_reg[index] <= temp[index];
            end
        end
        if(add) begin
            for(index = 0; index <= 31; index = index + 1) begin
                add_temp_reg[index] <= add_temp[index];
            end
        end
        if(end_add) begin
            result <= result_wire;
        end
    end
end

wire [511:0] B_T;
transpose trans(B_T, B);
genvar i, j, k;
generate
    for(i = 511; i >= 127; i = i - 128) begin
       for(j = 511; j >= 127; j = j - 128) begin
           for(k = 0; k <= 3; k = k + 1) begin
                mul m0(temp[-i/8 +511/8 -j/32 + 511/32 + k], A[i-32*k:i-31-32*k], B_T[j-32*k:j-31-32*k]);
           end
       end 
    end
endgenerate




genvar c;
generate
    for(c = 511; c >= 31; c = c - 32) begin
        adder a0(add_temp[-c/16 + 511/16 + 0], temp_reg[-c/8 + 511/8 + 0], temp_reg[-c/8 + 511/8 + 1]);
        adder a1(add_temp[-c/16 + 511/16 + 1], temp_reg[-c/8 + 511/8 + 2], temp_reg[-c/8 + 511/8 + 3]);
        adder a3(result_wire[c:c-31], add_temp_reg[-c/16 + 511/16 + 0], add_temp_reg[-c/16 + 511/16 + 1]);
    end
endgenerate


endmodule
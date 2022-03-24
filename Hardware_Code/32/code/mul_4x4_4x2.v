module mul_4x4_4x2(
    input clk, reset_n, start,
    input [511:0] A, 
    input [255:0] B,
    output done,
    output [255:0] result
);
wire  mul, add, end_add;
mul_4x4_4x2_controller controller(
    clk, reset_n, start, done, mul, add, end_add
);


mul_4x4_4x2_datapath datapath(
    clk, reset_n, A, B, mul, add, end_add, result
);


endmodule


module mul_4x4_4x2_controller(
    input clk, reset_n, start,
    output reg done,
    output mul, add, end_add
);

localparam  IDLE = 0,
            MUL  = 1,
            ADD  = 2,
            END_ADD = 3;
reg [1:0] current_state, next_state;

assign mul = (current_state == MUL);
assign add = (current_state == ADD);
assign end_add = (current_state == END_ADD);

reg done_reg;
always @(*) begin
    done_reg = 0;
    case(current_state)
    IDLE: next_state = start ? MUL : IDLE;
    MUL: next_state = ADD;
    ADD: next_state = END_ADD;
    END_ADD: begin
        done_reg = 1;
        next_state = IDLE;
    end
    default: next_state = IDLE;
    endcase
end

always @(posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        current_state <= IDLE;
        done <= 0;
    end
    else begin
        current_state <= next_state;
        done <= done_reg;
    end
end


endmodule

module mul_4x4_4x2_datapath(
    input clk, reset_n,
    input [511:0] A, 
    input [255:0] B,
    input mul, add, end_add,
    output reg [255:0] result
);

wire [31:0] temp[0:31];
reg [31:0] temp_reg[0:31];
wire [31:0] add_temp[0:15];
reg [31:0] add_temp_reg[0:15];
wire [255:0] result_wire;
integer index;

always @(posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        for(index = 0; index <= 31; index = index + 1) begin
            temp_reg[index] <= 0;
        end
        for(index = 0; index <= 15; index = index + 1) begin
            add_temp_reg[index] <= 0;
        end
        result <= 0;
    end
    else begin
        if(mul) begin
            for(index = 0; index <= 31; index = index + 1) begin
                temp_reg[index] <= temp[index];
            end
        end
        if(add) begin
            for(index = 0; index <= 15; index = index + 1) begin
                add_temp_reg[index] <= add_temp[index];
            end
        end
        if(end_add) begin
            result <= result_wire;
        end
    end
end

genvar i, j, k;
generate
    for(i = 511; i >= 127; i = i - 128) begin
       for(j = 255; j >= 223; j = j - 32) begin
           for(k = 0; k <= 3; k = k + 1) begin
                mul m0(temp[-i/16 + 511/16 -j/8 + 255/8 + k], A[i-32*k:i-31-32*k], B[j-64*k:j-31-64*k]);
           end
       end 
    end
endgenerate


genvar c;
generate
    for(c = 255; c >= 31; c = c - 32) begin
        adder a0(add_temp[-c/16 + 255/16 + 0], temp_reg[-c/8 + 255/8 + 0], temp_reg[-c/8 + 255/8 + 1]);
        adder a1(add_temp[-c/16 + 255/16 + 1], temp_reg[-c/8 + 255/8 + 2], temp_reg[-c/8 + 255/8 + 3]);
        adder a3(result_wire[c:c-31], add_temp_reg[-c/16 + 255/16 + 0], add_temp_reg[-c/16 + 255/16 + 1]);
    end
endgenerate

endmodule
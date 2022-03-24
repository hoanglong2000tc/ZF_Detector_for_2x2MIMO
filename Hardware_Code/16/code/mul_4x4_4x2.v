module mul_4x4_4x2(
    input clk, reset_n, start,
    input [255:0] A, 
    input [127:0] B,
    output done,
    output [127:0] result
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
    input [255:0] A, 
    input [127:0] B,
    input mul, add, end_add,
    output reg [127:0] result
);

wire [15:0] temp[0:31];
reg [15:0] temp_reg[0:31];
wire [15:0] add_temp[0:15];
reg [15:0] add_temp_reg[0:15];
wire [127:0] result_wire;
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
    for(i = 255; i >= 63; i = i - 64) begin
       for(j = 127; j >= 111; j = j - 16) begin
           for(k = 0; k <= 3; k = k + 1) begin
                mul m0(temp[-i/8 + 255/8 -j/4 + 127/4 + k], A[i-16*k:i-15-16*k]      , B[j-32*k:j-15-32*k]);
           end
       end 
    end
endgenerate


genvar c;
generate
    for(c = 127; c >= 15; c = c - 16) begin
        adder a0(add_temp[-c/8 + 127/8 + 0], temp_reg[-c/4 + 127/4 + 0], temp_reg[-c/4 + 127/4 + 1]);
        adder a1(add_temp[-c/8 + 127/8 + 1], temp_reg[-c/4 + 127/4 + 2], temp_reg[-c/4 + 127/4 + 3]);
        adder a3(result_wire[c:c-15], add_temp_reg[-c/8 + 127/8 + 0], add_temp_reg[-c/8 + 127/8 + 1]);
    end
endgenerate

endmodule
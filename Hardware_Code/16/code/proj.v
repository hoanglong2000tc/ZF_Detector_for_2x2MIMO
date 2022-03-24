module proj (
    output [63:0] proj,
    input [63:0] A,
    input [63:0] B,
    input clk, reset_n, start,
    output done
);
//projA_B = <B, A>A

wire cal_mul, add, end_add, mul, end_mul;
proj_controller controller(
    clk, reset_n, start, cal_mul, add, end_add, mul, end_mul, done
);

proj_datapath datapath(
    clk, reset_n, A, B, cal_mul, add, end_add, mul, end_mul, proj
);


endmodule
///
module proj_controller(
    input clk,
    input reset_n,
    input start,
    output cal_mul, add, end_add, mul, end_mul,
    output reg done
);
localparam  IDLE    = 0,
            CALMUL  = 1,
            ADD     = 2,
            END_ADD = 3,
            MUL     = 4,
            END_MUL = 5;

reg [2:0] current_state, next_state;

assign cal_mul = (current_state == CALMUL);
assign add = (current_state == ADD);
assign end_add = (current_state == END_ADD);
assign mul = (current_state == MUL);
assign end_mul = (current_state == END_MUL);

reg done_reg;
always @(*) begin
    done_reg = 0;
    case(current_state)
    IDLE: next_state = start ? CALMUL : IDLE;
    CALMUL: next_state = ADD;
    ADD: next_state = END_ADD;
    END_ADD: next_state = MUL;
    MUL: next_state = END_MUL;
    END_MUL: begin
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

module proj_datapath(
    input clk,
    input reset_n,
    input [63:0] A, B,
    input cal_mul, add, end_add, mul, end_mul,
    output reg [63:0] proj
);

wire [15:0] mul_res1, mul_res2, mul_res3, mul_res4, adder_res1, adder_res2;
reg [15:0] mul_in1_1, mul_in1_2, mul_in2_1, mul_in2_2, mul_in3_1, mul_in3_2, mul_in4_1, mul_in4_2,
        adder_in1_1, adder_in1_2, adder_in2_1, adder_in2_2;


mul mul1(mul_res1, mul_in1_1, mul_in1_2);
mul mul2(mul_res2, mul_in2_1, mul_in2_2);
mul mul3(mul_res3, mul_in3_1, mul_in3_2);
mul mul4(mul_res4, mul_in4_1, mul_in4_2);

adder adder1(adder_res1, adder_in1_1, adder_in1_2);
adder adder2(adder_res2, adder_in2_1, adder_in2_2);

always @(posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        proj <= 0;
        mul_in1_1 <= 0;
        mul_in1_2 <= 0;
        mul_in2_1 <= 0;
        mul_in2_2 <= 0;
        mul_in3_1 <= 0;
        mul_in3_2 <= 0;
        mul_in4_1 <= 0;
        mul_in4_2 <= 0;
        adder_in1_1 <= 0;
        adder_in1_2 <= 0;
        adder_in2_1 <= 0;
        adder_in2_2 <= 0;
    end
    else begin
        if(cal_mul) begin
            mul_in1_1 <= A[63:48];
            mul_in1_2 <= B[63:48];
            mul_in2_1 <= A[47:32];
            mul_in2_2 <= B[47:32];
            mul_in3_1 <= A[31:16];
            mul_in3_2 <= B[31:16];
            mul_in4_1 <= A[15:0];
            mul_in4_2 <= B[15:0];
        end
        if(add) begin
            adder_in1_1 <= mul_res1;
            adder_in1_2 <= mul_res2;
            adder_in2_1 <= mul_res3;
            adder_in2_2 <= mul_res4;
        end
        if(end_add) begin
            adder_in1_1 <= adder_res1;
            adder_in1_2 <= adder_res2;
        end
        if(mul) begin
            mul_in1_1 <= A[63:48];
            mul_in2_1 <= A[47:32];
            mul_in3_1 <= A[31:16];
            mul_in4_1 <= A[15:0];
            mul_in1_2 <= adder_res1;
            mul_in2_2 <= adder_res1;
            mul_in3_2 <= adder_res1;
            mul_in4_2 <= adder_res1;
        end
        if(end_mul) begin
            proj[63:48] <= mul_res1;
            proj[47:32] <= mul_res2;
            proj[31:16] <= mul_res3;
            proj[15:0] <= mul_res4;
        end
    end
end



endmodule
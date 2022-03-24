module matrix_4x1_subtracter (
    input [127:0] A, B,
    output [127:0] out
);
genvar i;
generate
    for(i = 127; i >= 31; i = i - 32) begin
        adder a__(out[i:i-31], A[i:i-31], {(1'b1 ^ B[i]), B[i-1:i-31]}); //subtract từng phần tử
    end 
endgenerate
endmodule
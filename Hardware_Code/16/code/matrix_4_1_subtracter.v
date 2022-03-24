module matrix_4x1_subtracter (
    input [63:0] A, B,
    output [63:0] out
);
genvar i;
generate
    for(i = 63; i >= 15; i = i - 16) begin
        adder a__(out[i:i-15], A[i:i-15], {(1'b1 ^ B[i]), B[i-1:i-15]}); //subtract từng phần tử
    end 
endgenerate

endmodule
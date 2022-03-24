module mul (
    output [31:0] C,
    input [31:0] A,
    input [31:0] B
);

assign C[31] = A[31]^B[31]; // sign bit

wire [54:0]temp;
assign temp = A[30:0] * B[30:0] >> 24;

assign C[30:0] = temp;
    
endmodule

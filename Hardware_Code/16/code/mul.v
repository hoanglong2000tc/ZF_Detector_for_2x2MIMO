module mul (
    output [15:0] C,
    input [15:0] A,
    input [15:0] B
);

assign C[15] = A[15]^B[15]; // sign bit

wire [26:0]temp;
assign temp = A[14:0] * B[14:0] >> 12;

assign C[14:0] = temp;
    
endmodule

module adder (
    output reg [31:0] C,
    input [31:0] A,
    input [31:0] B
);

always @(*) begin
    if(A[31] && B[31]) begin //cả 2 cùng âm
        C[31] = 1'b1;
        C[30:0] = A[30:0] + B[30:0];
    end
    else if(~A[31] && ~B[31]) begin //cả 2 cùng dương
        C[31] = 1'b0;
        C[30:0] = A[30:0] + B[30:0];
    end
    else if(~A[31] && B[31]) begin //A dương, B âm
        if(A[30:0] > B[30:0]) begin
            C[31] = 1'b0;
            C[30:0] = A[30:0] - B[30:0];
        end
        else if(A[30:0] == B[30:0]) begin
            C[31] = 1'b0;
            C[30:0] = 31'd0;
        end
        else begin
            C[31] = 1'b1;
            C[30:0] = B[30:0] - A[30:0];
        end
    end
    else begin //A âm, B dương
        if(A[30:0] > B[30:0]) begin
            C[31] = 1'b1;
            C[30:0] = A[30:0] - B[30:0];
        end
        else if(A[30:0] == B[30:0]) begin
            C[31] = 1'b0;
            C[30:0] = 31'd0;
        end
        else begin
            C[31] = 1'b0;
            C[30:0] = B[30:0] - A[30:0];
        end
    end
end
    
endmodule
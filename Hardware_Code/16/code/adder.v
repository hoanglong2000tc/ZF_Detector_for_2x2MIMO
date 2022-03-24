module adder (
    output reg [15:0] C,
    input [15:0] A,
    input [15:0] B
);

always @(*) begin
    if(A[15] && B[15]) begin //cả 2 cùng âm
        C[15] = 1'b1;
        C[14:0] = A[14:0] + B[14:0];
    end
    else if(~A[15] && ~B[15]) begin //cả 2 cùng dương
        C[15] = 1'b0;
        C[14:0] = A[14:0] + B[14:0];
    end
    else if(~A[15] && B[15]) begin //A dương, B âm
        if(A[14:0] > B[14:0]) begin
            C[15] = 1'b0;
            C[14:0] = A[14:0] - B[14:0];
        end
        else if(A[14:0] == B[14:0]) begin
            C[15] = 1'b0;
            C[14:0] = 15'd0;
        end
        else begin
            C[15] = 1'b1;
            C[14:0] = B[14:0] - A[14:0];
        end
    end
    else begin //A âm, B dương
        if(A[14:0] > B[14:0]) begin
            C[15] = 1'b1;
            C[14:0] = A[14:0] - B[14:0];
        end
        else if(A[14:0] == B[14:0]) begin
            C[15] = 1'b0;
            C[14:0] = 15'd0;
        end
        else begin
            C[15] = 1'b0;
            C[14:0] = B[14:0] - A[14:0];
        end
    end
end
    
endmodule
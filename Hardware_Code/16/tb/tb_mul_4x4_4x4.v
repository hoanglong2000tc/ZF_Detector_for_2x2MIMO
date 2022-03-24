module tb_mul_4x4_4x4;
reg enable, clk, reset_n, accept_in;
wire accept_out, ready_out;
    //
reg [255:0] A; 
reg [255:0] B;
wire [255:0] result;

mul_4x4_4x4 uut (enable, clk, reset_n, accept_in, accept_out, ready_out, A, B, result);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
initial begin
    reset_n = 0; @(negedge clk);
    reset_n = 1;
end
initial begin
    enable = 1;
    accept_in = 1;
end
always @(accept_out) begin
    if(accept_out) begin
        A = $random();
        B = $random();
    end
end

endmodule
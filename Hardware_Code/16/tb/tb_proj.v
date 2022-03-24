module tb_proj;

wire [63:0] proj;
reg [63:0] A;
reg [63:0] B;
reg clk, reset_n, start;
wire done;

proj uut(proj, A, B, clk, reset_n, start, done);
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
initial begin
    reset_n = 0; @(negedge clk);
    reset_n = 1;
end
initial begin
    start = 0; repeat(2) @(negedge clk);
    start = 1; @(negedge clk);
    start = 0;
end
initial begin
    A = 64'b1000011000111101000000011110101100001001100110010000011100110011;
    B = 64'b1000011000111101000000011110101100001001100110010000011100110011;
end
always @(done) begin
    if(done) $display("%b", proj);
end
endmodule
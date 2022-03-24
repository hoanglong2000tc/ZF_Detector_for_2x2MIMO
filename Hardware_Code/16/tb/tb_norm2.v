module tb_norm2;
reg [63:0] vector;
reg enable, clk, reset_n, accept_in;
wire accept_out, ready_out;
wire [15:0] res;

norm2 uut(vector, enable, clk, reset_n, accept_in, accept_out, ready_out, res);

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

reg [63:0] in [0 : 1];
initial begin
    in[0] = 64'b0000100010100011000001110000101000001000010100010000011001100110;
    in[1] = 64'b0000011100001010000001100110011000000111110101110000011101011100;
end
reg i = 0;
always @(accept_out) begin
    if(accept_out) begin
        vector = in[i];
        i = i + 1;
    end
end
endmodule
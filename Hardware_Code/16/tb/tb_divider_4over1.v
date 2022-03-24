module tb_divider_4over1;
reg enable, clk, reset_n, accept_in;
wire accept_out, ready_out;
//
reg [63:0] Q; 
reg [15:0] M;
wire [63:0] quot;




divider_4over1 uut (enable, clk, reset_n, accept_in, accept_out, ready_out, Q, M, quot);
 
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

reg [63:0] inQ [0 : 1];
reg [15:0] inM [0 : 1];

initial begin
    inQ[0] = 64'b0000100010100011000001110000101000001000010100010000011001100110;
    inQ[1] = 64'b0000011100001010000001100110011000000111110101110000011101011100;

    inM[0] = 16'b0011001100110011;//3.2
    inM[1] = 16'b0101000000000000;//5
end
reg i = 0;

always @(accept_out) begin
    if(accept_out) begin
        Q = inQ[i];
        M = inM[i];
        i = i + 1;
    end
end
endmodule

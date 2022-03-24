module tb_divider;
reg enable, clk, reset_n, accept_in;
wire accept_out, ready_out;
//
reg [15:0] Q, M;
wire [15:0] quot;




divider uut (enable, clk, reset_n, accept_in, accept_out, ready_out, Q, M, quot);
 
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
// initial begin
//     Q = 16'b0010101100110011;
//     M = 16'b0001010011001100;
// end

reg [15:0] inQ [0 : 1];
reg [15:0] inM [0 : 1];

initial begin
    inQ[0] = 16'b0100100110011001; //4.6
    inQ[1] = 16'b0010110011001100; //2.8

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
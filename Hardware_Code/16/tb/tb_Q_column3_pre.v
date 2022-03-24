module tb_Q_column3_pre;
reg enable, clk, reset_n, accept_in;
wire accept_out, ready_out;
//
reg [63:0] H_col3, Q_col1, Q_col2;
wire [63:0] Q_col3_pre;

Q_column3_pre uut(
    enable, clk, reset_n, accept_in,
    accept_out, ready_out, H_col3, Q_col1, Q_col2, Q_col3_pre
);
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
    in[0] = 64'b0000110011001100000010011001100100000110011001100000100110011001;
    in[1] = 64'b0000100110011001000100110011001100001001100110010000110000101000;
end
reg i;
initial i = 0;
always @(accept_out) begin
    if(accept_out) begin
        Q_col1 = in[i];
        Q_col2 = in[i];
        H_col3 = in[i];
        i = i + 1;
    end
end

endmodule



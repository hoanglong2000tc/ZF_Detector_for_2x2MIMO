module tb_midprocess_ZF;
    reg enable, clk, reset_n, accept_in;
    wire accept_out, ready_out;
//
    reg [31:0] Q_processed_2; //2 phần tử hàng 2 của Q_processed
    reg [31:0] R; //2 phần tử bên phải hàng 2 của R
    reg [31:0] X_pre; //2 phần tử hàng cuối (đã tính được của X)
    wire [31:0] X_mid_pre; // ma trận X

midprocess_ZF uut(enable, clk, reset_n, accept_in, accept_out, ready_out, Q_processed_2, R, X_pre, X_mid_pre);

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

initial begin
    Q_processed_2 = 32'b00110011001100110001110011001100;
    R = 32'b00001001100110010000011001100110;
    X_pre = 32'b00000110011001100000111001100110;
end



endmodule

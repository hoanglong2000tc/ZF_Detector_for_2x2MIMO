module divider(
    input enable, clk, reset_n, accept_in,
    output accept_out, ready_out,
//
    input [31:0] Q, M,
    output [31:0] quot
);
//xử lý bit dấu
assign quot[31] = Q[31] ^ M[31];
/*
còn 31 bit cần phải xử lý, mà phần thập phân có 24 bit. suy ra cần dịch trái dividend 24 bit để xử lý toàn bộ dữ liệu 
=> tổng cần 1 reg 24 + 31 = 55 bit reg để xử lý, cũng có nghĩa là mình không quan tâm đến remainder nữa


-> đoạn code dưới sẽ chỉ sử dụng 31 bit đầu tiên của Q và M để xử lý ([30:0])
*/
wire [54:0] Q_reg;
assign Q_reg = Q[30:0] << 24;

wire [54:0] M_reg, quot_reg;
assign quot[30:0] = quot_reg;
assign M_reg = {24'd0, M[30:0]};
non_restoring_divider #(.N(55)) non_restoring_divider(
    enable, clk, reset_n, accept_in,
    accept_out, ready_out,
//
    M_reg, Q_reg, quot_reg
);


endmodule
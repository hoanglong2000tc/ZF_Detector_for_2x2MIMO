module divider(
    input enable, clk, reset_n, accept_in,
    output accept_out, ready_out,
//
    input [15:0] Q, M,
    output [15:0] quot
);
//xử lý bit dấu
assign quot[15] = Q[15] ^ M[15];
/*
còn 15 bit cần phải xử lý, mà phần thập phân có 12 bit. suy ra cần dịch trái dividend 12 bit để xử lý toàn bộ dữ liệu 
=> tổng cần 1 reg 12 + 15 = 27 bit reg để xử lý, cũng có nghĩa là mình không quan tâm đến remainder nữa


-> đoạn code dưới sẽ chỉ sử dụng 15 bit đầu tiên của Q và M để xử lý ([14:0])
*/
wire [26:0] Q_reg;
assign Q_reg = Q[14:0] << 12;

wire [26:0] M_reg, quot_reg;
assign quot[14:0] = quot_reg;
assign M_reg = {12'd0, M[14:0]};
non_restoring_divider #(.N(27)) non_restoring_divider(
    enable, clk, reset_n, accept_in,
    accept_out, ready_out,
//
    M_reg, Q_reg, quot_reg
);


endmodule
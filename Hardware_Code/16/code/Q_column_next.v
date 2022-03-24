module Q_column_next(
    output [63:0] Q_col_next,
    input [63:0] Q_col    
);
assign Q_col_next[63:48] = {1'b1 ^ Q_col[47], Q_col[46:32]};
assign Q_col_next[47:32] = Q_col[63:48];
assign Q_col_next[31:16] = {1'b1 ^ Q_col[15], Q_col[14:0]};
assign Q_col_next[15:0] = Q_col[31:16];


endmodule

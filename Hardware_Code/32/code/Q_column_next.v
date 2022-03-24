module Q_column_next(
    output [127:0] Q_col_next,
    input [127:0] Q_col    
);
assign Q_col_next[127:96] = {1'b1 ^ Q_col[95], Q_col[94:64]};
assign Q_col_next[95:64] = Q_col[127:96];
assign Q_col_next[63:32] = {1'b1 ^ Q_col[31], Q_col[30:0]};
assign Q_col_next[31:0] = Q_col[63:32];


endmodule

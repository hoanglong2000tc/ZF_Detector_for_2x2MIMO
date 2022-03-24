module ZF(
    input enable, clk, reset_n, accept_in,
    output accept_out, 
    output reg ready_out,

    input [511:0] H_matrix,
    input [255:0] y, n,
    output reg [255:0] X
);

wire [127:0] H_col1, H_col2, H_col3, H_col4;
transpose transposeH({H_col1, H_col2, H_col3, H_col4}, H_matrix);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//stage1
wire [31:0] res_norm2_Q_column1;
reg [127:0] H_col1_stage1, H_col2_stage1, H_col3_stage1, H_col4_stage1;
reg [255:0] y_stage1, n_stage1;
//stage2
reg [31:0] res_norm2_Q_column1_stage2;
reg [127:0] H_col1_stage2, H_col2_stage2, H_col3_stage2, H_col4_stage2;
reg [255:0] y_stage2, n_stage2;
wire [127:0] Q_col1, Q_col2;
//stage3
reg [127:0] H_col1_stage3, H_col2_stage3, H_col3_stage3, H_col4_stage3, Q_col1_stage3, Q_col2_stage3;
reg [255:0] y_stage3, n_stage3;
wire [127:0] Q_col3_pre;
//stage4
wire [31:0] res_norm2_Q_column3;
reg [127:0] H_col1_stage4, H_col2_stage4, H_col3_stage4, H_col4_stage4, Q_col1_stage4, Q_col2_stage4, Q_col3_pre_stage4;
reg [255:0] y_stage4, n_stage4;
//stage5
reg [31:0] res_norm2_Q_column3_stage5;
reg [127:0] H_col1_stage5, H_col2_stage5, H_col3_stage5, H_col4_stage5, Q_col1_stage5, Q_col2_stage5, Q_col3_pre_stage5;
reg [255:0] y_stage5, n_stage5;
wire [127:0] Q_col3, Q_col4;
//stage6
reg [127:0] H_col1_stage6, H_col2_stage6, H_col3_stage6, H_col4_stage6, Q_col1_stage6, Q_col2_stage6, Q_col3_stage6, Q_col4_stage6;
reg [255:0] y_stage6, n_stage6;
wire [511:0] R_matrixR;
//stage7
reg [255:0] y_stage7, n_stage7;
reg [511:0] R_matrix_stage7, invQ_stage7;
wire [255:0] Q_processed;
//stage8
reg [63:0] Q_processed_in_stage8, Q_processed_store_stage8;
reg [31:0] R_matrix_in_stage8; //phần tử góc dưới bên phải ma trận R
reg [95:0] R_matrix_store_stage8; //3 phần tử hàng 2 ma trận R
wire [63:0] X_pre;//2 phần tử dưới cùng của X
//stage9
reg [63:0] Q_processed_in_stage9, R_matrix_in_stage9, X_pre_stage9;
reg [31:0] R_matrix_store_stage9; // phần tử tại hàng 2 cột 1 ma trận R
wire [63:0] X_mid_pre;
//stage10
reg [31:0] R_matrix_in_stage10;
reg [63:0] X_pre_stage10, X_mid_pre_stage10;
wire [63:0] X_mid;
//////////////////////////////////////////////////////////////////////////////////////
//tính norm2 cột 1 của Q (stage1)
norm2 norm2_Q_column1(H_col1_stage1, enable, clk, reset_n, accept_out_Q_column1, accept_out, ready_out_norm2_Q_column1, res_norm2_Q_column1);
//tính cột 1 (stage2)
divider_4over1 Q_column1(ready_out_norm2_Q_column1, clk, reset_n, accept_out_Q_column3_pre, accept_out_Q_column1, ready_out_Q_column1,
H_col1_stage2, res_norm2_Q_column1_stage2, Q_col1);
Q_column_next Q_column2(Q_col2, Q_col1);
//tiền xử lý cột 3 (stage3)
Q_column3_pre Q_column3_pre(
    ready_out_Q_column1, clk, reset_n, accept_out_norm2_Q_column3, accept_out_Q_column3_pre, ready_out_Q_column3_pre,
    H_col3_stage3, Q_col1_stage3, Q_col2_stage3, Q_col3_pre
);
//tính norm2 cột 3 (stage4)
norm2 norm2_Q_column3(Q_col3_pre_stage4, ready_out_Q_column3_pre, clk, reset_n, accept_out_Q_column3, accept_out_norm2_Q_column3, ready_out_norm2_Q_column3, res_norm2_Q_column3);
//tính cột 3 (stage5)
divider_4over1 Q_column3(ready_out_norm2_Q_column3, clk, reset_n, accept_outR, accept_out_Q_column3, ready_out_Q_column3, Q_col3_pre_stage5, res_norm2_Q_column3_stage5, Q_col3);
Q_column_next Q_column4(Q_col4, Q_col3);
//tính R (stage6)
wire [511:0] H_matrixR;//, Q_matrixR;
transpose transposeH_R(H_matrixR, {H_col1_stage6, H_col2_stage6, H_col3_stage6, H_col4_stage6});
// transpose transposeQ_R(Q_matrixR, {Q_col1_stage6, Q_col2_stage6, Q_col3_stage6, Q_col4_stage6});
mul_4x4_4x4 R_decomposition(
    ready_out_Q_column3, clk, reset_n, accept_out_preprocess_ZF, accept_outR, ready_outR,
    {Q_col1_stage6, Q_col2_stage6, Q_col3_stage6, Q_col4_stage6}, 
    H_matrixR,
    R_matrixR
);
//preprocess ZF (stage7)
preprocess_ZF preprocess_ZF(ready_outR, clk, reset_n, accept_out_X_PRE, accept_out_preprocess_ZF, ready_out_preprocess_ZF,
y_stage7, n_stage7, invQ_stage7, Q_processed);
//tính 2 phần tử dưới cùng của X (stage8)
divider_2over1 X_PRE (ready_out_preprocess_ZF, clk, reset_n, accept_out_midprocess_ZF, accept_out_X_PRE, ready_out_X_PRE,
Q_processed_in_stage8, R_matrix_in_stage8, X_pre);
//midprocess ZF (stage9)
midprocess_ZF midprocess_ZF(ready_out_X_PRE, clk, reset_n, accept_out_X_MID, accept_out_midprocess_ZF, ready_out_midprocess_ZF,
Q_processed_in_stage9, R_matrix_in_stage9, X_pre_stage9, X_mid_pre);
//Tính 2 phần tử hàng thứ 2 của X (stage10)
divider_2over1 X_MID (ready_out_midprocess_ZF, clk, reset_n, accept_in, accept_out_X_MID, ready_out_last,
X_mid_pre_stage10, R_matrix_in_stage10, X_mid);
//
///////////////////////////////////////////////////////////////////////////////////////////////////////


always @(posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        {H_col1_stage1, H_col2_stage1, H_col3_stage1, H_col4_stage1, y_stage1, n_stage1} <= 0;
        {H_col1_stage2, H_col2_stage2, H_col3_stage2, H_col4_stage2, res_norm2_Q_column1_stage2, y_stage2, n_stage2} <= 0;
        {H_col1_stage3, H_col2_stage3, H_col3_stage3, H_col4_stage3, Q_col1_stage3, Q_col2_stage3, y_stage3, n_stage3} <= 0;
        {H_col1_stage4, H_col2_stage4, H_col3_stage4, H_col4_stage4, Q_col1_stage4, Q_col2_stage4, Q_col3_pre_stage4, y_stage4, n_stage4} <= 0;
        {H_col1_stage5, H_col2_stage5, H_col3_stage5, H_col4_stage5, Q_col1_stage5, Q_col2_stage5, Q_col3_pre_stage5, res_norm2_Q_column3_stage5, y_stage5, n_stage5} <= 0;
        {H_col1_stage6, H_col2_stage6, H_col3_stage6, H_col4_stage6, Q_col1_stage6, Q_col2_stage6, Q_col3_stage6, Q_col4_stage6, y_stage6, n_stage6} <= 0;
        {R_matrix_stage7, invQ_stage7, y_stage7, n_stage7} <= 0;
        {Q_processed_in_stage8, Q_processed_store_stage8, R_matrix_in_stage8, R_matrix_store_stage8} <= 0;
        {Q_processed_in_stage9, R_matrix_in_stage9, X_pre_stage9, R_matrix_store_stage9} <= 0;
        {R_matrix_in_stage10, X_pre_stage10, X_mid_pre_stage10} <= 0;
        X <= 0;
        ready_out <= 0;
    end
    else begin
        ready_out <= ready_out_last;
        if(accept_out) {H_col1_stage1, H_col2_stage1, H_col3_stage1, H_col4_stage1, y_stage1, n_stage1} <= {H_col1, H_col2, H_col3, H_col4, y, n};
        if(accept_out_Q_column1 && ready_out_norm2_Q_column1) {H_col1_stage2, H_col2_stage2, H_col3_stage2, H_col4_stage2, res_norm2_Q_column1_stage2, y_stage2, n_stage2} <= {H_col1_stage1, H_col2_stage1, H_col3_stage1, H_col4_stage1, res_norm2_Q_column1, y_stage1, n_stage1};
        if(accept_out_Q_column3_pre && ready_out_Q_column1) 
        {H_col1_stage3, H_col2_stage3, H_col3_stage3, H_col4_stage3, Q_col1_stage3, Q_col2_stage3, y_stage3, n_stage3} <= {H_col1_stage2, H_col2_stage2, H_col3_stage2, H_col4_stage2, Q_col1, Q_col2, y_stage2, n_stage2};
        if(accept_out_norm2_Q_column3 && ready_out_Q_column3_pre) 
        {H_col1_stage4, H_col2_stage4, H_col3_stage4, H_col4_stage4, Q_col1_stage4, Q_col2_stage4, Q_col3_pre_stage4, y_stage4, n_stage4} <= {H_col1_stage3, H_col2_stage3, H_col3_stage3, H_col4_stage3, Q_col1_stage3, Q_col2_stage3 ,Q_col3_pre, y_stage3, n_stage3};
        if(accept_out_Q_column3 && ready_out_norm2_Q_column3)
        {H_col1_stage5, H_col2_stage5, H_col3_stage5, H_col4_stage5, Q_col1_stage5, Q_col2_stage5, Q_col3_pre_stage5, res_norm2_Q_column3_stage5, y_stage5, n_stage5} <= 
        {H_col1_stage4, H_col2_stage4, H_col3_stage4, H_col4_stage4, Q_col1_stage4, Q_col2_stage4, Q_col3_pre_stage4, res_norm2_Q_column3, y_stage4, n_stage4};
        if(accept_outR && ready_out_Q_column3)
        {H_col1_stage6, H_col2_stage6, H_col3_stage6, H_col4_stage6, Q_col1_stage6, Q_col2_stage6, Q_col3_stage6, Q_col4_stage6, y_stage6, n_stage6} <=
        {H_col1_stage5, H_col2_stage5, H_col3_stage5, H_col4_stage5, Q_col1_stage5, Q_col2_stage5, Q_col3, Q_col4, y_stage5, n_stage5};
        if(accept_out_preprocess_ZF && ready_outR) {R_matrix_stage7, invQ_stage7, y_stage7, n_stage7} <= {R_matrixR, Q_col1_stage6, Q_col2_stage6, Q_col3_stage6, Q_col4_stage6, y_stage6, n_stage6};
        if(accept_out_X_PRE && ready_out_preprocess_ZF) {Q_processed_in_stage8, Q_processed_store_stage8, R_matrix_in_stage8, R_matrix_store_stage8} <=
        {Q_processed[63:0], Q_processed[191:128], R_matrix_stage7[31:0], R_matrix_stage7[351:256]};
        if(accept_out_midprocess_ZF && ready_out_X_PRE) 
        {Q_processed_in_stage9, R_matrix_in_stage9, X_pre_stage9, R_matrix_store_stage9} <= {Q_processed_store_stage8, R_matrix_store_stage8[63:0], X_pre, R_matrix_store_stage8[95:64]};
        if(accept_out_X_MID && ready_out_midprocess_ZF)
        {R_matrix_in_stage10, X_pre_stage10, X_mid_pre_stage10} <= {R_matrix_store_stage9, X_pre_stage9, X_mid_pre};
        if(ready_out_last) begin
            X[191:128] <= X_mid;
            X[63:0] <= X_pre_stage10;
            X[127:96] <= X_pre_stage10[31:0];
            X[95:64] <= {1'b1^X_pre_stage10[63], X_pre_stage10[62:32]};
            X[255:224] <= X_mid[31:0];
            X[223:192] <= {1'b1^X_mid[63], X_mid[62:32]};
        end

    end
end
    
endmodule





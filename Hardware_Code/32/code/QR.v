module QR(
    input enable, clk, reset_n, accept_in,
    output accept_out, 
    output reg ready_out,

    input [511:0] H_matrix,
    output reg [511:0] Q_matrix, R_matrix
);

wire [127:0] H_col1, H_col2, H_col3, H_col4;
transpose transposeH({H_col1, H_col2, H_col3, H_col4}, H_matrix);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//stage1
wire [31:0] res_norm2_Q_column1;
reg [127:0] H_col1_stage1, H_col2_stage1, H_col3_stage1, H_col4_stage1;
//stage2
reg [31:0] res_norm2_Q_column1_stage2;
reg [127:0] H_col1_stage2, H_col2_stage2, H_col3_stage2, H_col4_stage2;
wire [127:0] Q_col1, Q_col2;
//stage3
reg [127:0] H_col1_stage3, H_col2_stage3, H_col3_stage3, H_col4_stage3, Q_col1_stage3, Q_col2_stage3;
wire [127:0] Q_col3_pre;
//stage4
wire [31:0] res_norm2_Q_column3;
reg [127:0] H_col1_stage4, H_col2_stage4, H_col3_stage4, H_col4_stage4, Q_col1_stage4, Q_col2_stage4, Q_col3_pre_stage4;
//stage5
reg [31:0] res_norm2_Q_column3_stage5;
reg [127:0] H_col1_stage5, H_col2_stage5, H_col3_stage5, H_col4_stage5, Q_col1_stage5, Q_col2_stage5, Q_col3_pre_stage5;
wire [127:0] Q_col3, Q_col4;
//stage6
reg [127:0] H_col1_stage6, H_col2_stage6, H_col3_stage6, H_col4_stage6, Q_col1_stage6, Q_col2_stage6, Q_col3_stage6, Q_col4_stage6;
wire [511:0] R_matrixR;
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
wire accept_inR;
assign accept_inR = 1;
wire [511:0] H_matrixR, Q_matrixR;
transpose transposeH_R(H_matrixR, {H_col1_stage6, H_col2_stage6, H_col3_stage6, H_col4_stage6});
transpose transposeQ_R(Q_matrixR, {Q_col1_stage6, Q_col2_stage6, Q_col3_stage6, Q_col4_stage6});
mul_4x4_4x4 R_decomposition(
    ready_out_Q_column3, clk, reset_n, accept_inR, accept_outR, ready_outR,
    
    {Q_col1_stage6, Q_col2_stage6, Q_col3_stage6, Q_col4_stage6}, 
    H_matrixR,
    R_matrixR
);
///////////////////////////////////////////////////////////////////////////////////////////////////////


always @(posedge clk, negedge reset_n) begin
    if(~reset_n) begin
        {H_col1_stage1, H_col2_stage1, H_col3_stage1, H_col4_stage1} <= 0;
        {H_col1_stage2, H_col2_stage2, H_col3_stage2, H_col4_stage2, res_norm2_Q_column1_stage2} <= 0;
        {H_col1_stage3, H_col2_stage3, H_col3_stage3, H_col4_stage3, Q_col1_stage3, Q_col2_stage3} <= 0;
        {H_col1_stage4, H_col2_stage4, H_col3_stage4, H_col4_stage4, Q_col1_stage4, Q_col2_stage4, Q_col3_pre_stage4} <= 0;
        {H_col1_stage5, H_col2_stage5, H_col3_stage5, H_col4_stage5, Q_col1_stage5, Q_col2_stage5, Q_col3_pre_stage5, res_norm2_Q_column3_stage5} <= 0;
        {H_col1_stage6, H_col2_stage6, H_col3_stage6, H_col4_stage6, Q_col1_stage6, Q_col2_stage6, Q_col3_stage6, Q_col4_stage6} <= 0;
        Q_matrix <= 0;
        R_matrix <= 0;
        ready_out <= 0;
    end
    else begin
        ready_out <= ready_outR;
        if(accept_out) {H_col1_stage1, H_col2_stage1, H_col3_stage1, H_col4_stage1} <= {H_col1, H_col2, H_col3, H_col4};
        if(accept_out_Q_column1 && ready_out_norm2_Q_column1) {H_col1_stage2, H_col2_stage2, H_col3_stage2, H_col4_stage2, res_norm2_Q_column1_stage2} <= {H_col1_stage1, H_col2_stage1, H_col3_stage1, H_col4_stage1, res_norm2_Q_column1};
        if(accept_out_Q_column3_pre && ready_out_Q_column1) 
        {H_col1_stage3, H_col2_stage3, H_col3_stage3, H_col4_stage3, Q_col1_stage3, Q_col2_stage3} <= {H_col1_stage2, H_col2_stage2, H_col3_stage2, H_col4_stage2, Q_col1, Q_col2};
        if(accept_out_norm2_Q_column3 && ready_out_Q_column3_pre) 
        {H_col1_stage4, H_col2_stage4, H_col3_stage4, H_col4_stage4, Q_col1_stage4, Q_col2_stage4, Q_col3_pre_stage4} <= {H_col1_stage3, H_col2_stage3, H_col3_stage3, H_col4_stage3, Q_col1_stage3, Q_col2_stage3 ,Q_col3_pre};
        if(accept_out_Q_column3 && ready_out_norm2_Q_column3)
        {H_col1_stage5, H_col2_stage5, H_col3_stage5, H_col4_stage5, Q_col1_stage5, Q_col2_stage5, Q_col3_pre_stage5, res_norm2_Q_column3_stage5} <= 
        {H_col1_stage4, H_col2_stage4, H_col3_stage4, H_col4_stage4, Q_col1_stage4, Q_col2_stage4, Q_col3_pre_stage4, res_norm2_Q_column3};
        if(accept_outR && ready_out_Q_column3)
        {H_col1_stage6, H_col2_stage6, H_col3_stage6, H_col4_stage6, Q_col1_stage6, Q_col2_stage6, Q_col3_stage6, Q_col4_stage6} <=
        {H_col1_stage5, H_col2_stage5, H_col3_stage5, H_col4_stage5, Q_col1_stage5, Q_col2_stage5, Q_col3, Q_col4};
        if(ready_outR) begin
            Q_matrix <= Q_matrixR;
            R_matrix <= R_matrixR;
        end
    end
end
    
endmodule




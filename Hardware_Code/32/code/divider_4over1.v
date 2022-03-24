module divider_4over1(
    input enable, clk, reset_n, accept_in,
    output accept_out, ready_out,
    //
    input [127:0] vec, 
    input [31:0] el,
    output [127:0] res
);
wire [3:0] accept_outs, ready_outs;

assign accept_out = (accept_outs == 4'b1111);
assign ready_out = (ready_outs == 4'b1111);
genvar i;
generate
    for(i = 0; i <= 3; i = i + 1) begin
        divider divider(
            enable, clk, reset_n, accept_in, accept_outs[i], ready_outs[i], 
            vec[127-i*32:127-i*32-31], 
            el, 
            res[127-i*32:127-i*32-31]
        );
    end
endgenerate


endmodule
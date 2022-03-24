module divider_4over1(
    input enable, clk, reset_n, accept_in,
    output accept_out, ready_out,
    //
    input [63:0] vec, 
    input [15:0] el,
    output [63:0] res
);
wire [3:0] accept_outs, ready_outs;

assign accept_out = (accept_outs == 4'b1111);
assign ready_out = (ready_outs == 4'b1111);
genvar i;
generate
    for(i = 0; i <= 3; i = i + 1) begin
        divider divider(
            enable, clk, reset_n, accept_in, accept_outs[i], ready_outs[i], 
            vec[63-i*16:63-i*16-15], 
            el, 
            res[63-i*16:63-i*16-15]
        );
    end
endgenerate


endmodule

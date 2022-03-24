module divider_2over1(
    input enable, clk, reset_n, accept_in,
    output accept_out, ready_out,
    //
    input [63:0] vec, 
    input [31:0] el,
    output [63:0] res
);
wire [1:0] accept_outs, ready_outs;

assign accept_out = (accept_outs == 2'b11);
assign ready_out = (ready_outs == 2'b11);

divider divider1(
    enable, clk, reset_n, accept_in, accept_outs[0], ready_outs[0], 
    vec[63:32], 
    el, 
    res[63:32]
);

divider divider2(
    enable, clk, reset_n, accept_in, accept_outs[1], ready_outs[1], 
    vec[31:0], 
    el, 
    res[31:0]
);



endmodule
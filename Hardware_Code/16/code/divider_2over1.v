module divider_2over1(
    input enable, clk, reset_n, accept_in,
    output accept_out, ready_out,
    //
    input [31:0] vec, 
    input [15:0] el,
    output [31:0] res
);
wire [1:0] accept_outs, ready_outs;

assign accept_out = (accept_outs == 2'b11);
assign ready_out = (ready_outs == 2'b11);

divider divider1(
    enable, clk, reset_n, accept_in, accept_outs[0], ready_outs[0], 
    vec[31:16], 
    el, 
    res[31:16]
);

divider divider2(
    enable, clk, reset_n, accept_in, accept_outs[1], ready_outs[1], 
    vec[15:0], 
    el, 
    res[15:0]
);



endmodule
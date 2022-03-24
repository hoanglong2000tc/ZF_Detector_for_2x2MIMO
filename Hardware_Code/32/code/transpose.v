module transpose(
    output [511:0] out,
    input [511:0] in
);
assign out[511:480] = in[511:480];
assign out[479:448] = in[383:352];
assign out[383:352] = in[479:448];
assign out[447:416] = in[255:224];
assign out[255:224] = in[447:416];
assign out[415:384] = in[127:96];
assign out[127:96]  = in[415:384];
assign out[351:320] = in[351:320];
assign out[319:288] = in[223:192];
assign out[223:192] = in[319:288];
assign out[287:256] = in[95:64];
assign out[95:64]   = in[287:256];
assign out[191:160] = in[191:160];
assign out[63:32]   = in[159:128];
assign out[159:128] = in[63:32];
assign out[31:0]    = in[31:0];

endmodule
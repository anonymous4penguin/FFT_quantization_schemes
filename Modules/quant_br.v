module quant_br #(
    parameter WIDTH = 16
)(
    input  signed [WIDTH:0] din,
    output signed [WIDTH-1:0] dout
);

assign dout = (din + 1'b1) >>> 1;

endmodule
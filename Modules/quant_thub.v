`timescale 1ns / 1ps

module quant_thub #(
    parameter WIDTH = 16,
    parameter IS_ADD = 1
)(
    input  signed [WIDTH:0] din,
    output signed [WIDTH-1:0] dout
);

wire signed [WIDTH:0] biased;

assign biased = din + 1'b1;

assign dout =
    (IS_ADD) ?
    (biased >>> 1) :
    (din >>> 1);

endmodule

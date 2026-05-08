module quant_hub #(
    parameter WIDTH = 16
)(
    input  signed [WIDTH:0] din,
    output signed [WIDTH-1:0] dout
);

wire signed [WIDTH:0] biased;

assign biased = din + 1'b1;

assign dout = biased >>> 1;

endmodule
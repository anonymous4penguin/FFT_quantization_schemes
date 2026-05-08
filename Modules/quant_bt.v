module quant_bt #(
    parameter WIDTH = 16
)(
    input  signed [WIDTH:0] din,
    output signed [WIDTH-1:0] dout
);

assign dout = din >>> 1;

endmodule
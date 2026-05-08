module quantizer #(
    parameter WIDTH = 16,

    // 0 = BT
    // 1 = BR
    // 2 = HUB
    // 3 = THUB

    parameter MODE = 0,

    parameter IS_ADD = 1
)(
    input  signed [WIDTH:0] din,
    output signed [WIDTH-1:0] dout
);

generate

if (MODE == 0)
begin
    quant_bt #(WIDTH) q (
        .din(din),
        .dout(dout)
    );
end

else if (MODE == 1)
begin
    quant_br #(WIDTH) q (
        .din(din),
        .dout(dout)
    );
end

else if (MODE == 2)
begin
    quant_hub #(WIDTH) q (
        .din(din),
        .dout(dout)
    );
end

else
begin
    quant_thub #(
        .WIDTH(WIDTH),
        .IS_ADD(IS_ADD)
    )
    q (
        .din(din),
        .dout(dout)
    );
end

endgenerate

endmodule
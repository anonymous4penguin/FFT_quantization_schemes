// Butterfly
// Radix-2 Butterfly with Quantization

module Butterfly #(

    parameter WIDTH = 16,

    // QUANTIZATION MODE
    // 0 = BT
    // 1 = BR
    // 2 = HUB
    // 3 = THUB

    parameter QMODE = 0

)(
    input  signed [WIDTH-1:0] x0_re,
    input  signed [WIDTH-1:0] x0_im,

    input  signed [WIDTH-1:0] x1_re,
    input  signed [WIDTH-1:0] x1_im,

    output signed [WIDTH-1:0] y0_re,
    output signed [WIDTH-1:0] y0_im,

    output signed [WIDTH-1:0] y1_re,
    output signed [WIDTH-1:0] y1_im
);


    // INTERNAL SIGNALS

    wire signed [WIDTH:0] add_re;
    wire signed [WIDTH:0] add_im;

    wire signed [WIDTH:0] sub_re;
    wire signed [WIDTH:0] sub_im;


    // ADD / SUB

    assign add_re = x0_re + x1_re;
    assign add_im = x0_im + x1_im;

    assign sub_re = x0_re - x1_re;
    assign sub_im = x0_im - x1_im;


    // QUANTIZATION

    quantizer #(
        .WIDTH(WIDTH),
        .MODE(QMODE),
        .IS_ADD(1)
    )
    Q_ADD_RE (
        .din(add_re),
        .dout(y0_re)
    );

    quantizer #(
        .WIDTH(WIDTH),
        .MODE(QMODE),
        .IS_ADD(1)
    )
    Q_ADD_IM (
        .din(add_im),
        .dout(y0_im)
    );

    quantizer #(
        .WIDTH(WIDTH),
        .MODE(QMODE),
        .IS_ADD(0)
    )
    Q_SUB_RE (
        .din(sub_re),
        .dout(y1_re)
    );

    quantizer #(
        .WIDTH(WIDTH),
        .MODE(QMODE),
        .IS_ADD(0)
    )
    Q_SUB_IM (
        .din(sub_im),
        .dout(y1_im)
    );

endmodule
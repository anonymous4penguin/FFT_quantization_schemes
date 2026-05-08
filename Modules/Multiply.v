// Multiply
// Complex Multiplier with Quantization

module Multiply #(

    parameter WIDTH = 16,


    // QUANTIZATION MODE
    // 0 = BT
    // 1 = BR
    // 2 = HUB
    // 3 = THUB

    parameter QMODE = 0

)(
    input signed [WIDTH-1:0] a_re,
    input signed [WIDTH-1:0] a_im,

    input signed [WIDTH-1:0] b_re,
    input signed [WIDTH-1:0] b_im,

    output signed [WIDTH-1:0] m_re,
    output signed [WIDTH-1:0] m_im
);

    // MULTIPLICATION RESULTS

    wire signed [2*WIDTH-1:0] arbr;
    wire signed [2*WIDTH-1:0] arbi;

    wire signed [2*WIDTH-1:0] aibr;
    wire signed [2*WIDTH-1:0] aibi;


    // SCALED VALUES

    wire signed [WIDTH-1:0] sc_arbr;
    wire signed [WIDTH-1:0] sc_arbi;

    wire signed [WIDTH-1:0] sc_aibr;
    wire signed [WIDTH-1:0] sc_aibi;


    // FINAL ADD/SUB

    wire signed [WIDTH:0] temp_re;
    wire signed [WIDTH:0] temp_im;


    // COMPLEX MULTIPLICATION

    assign arbr = a_re * b_re;
    assign arbi = a_re * b_im;

    assign aibr = a_im * b_re;
    assign aibi = a_im * b_im;

    // SCALE BACK TO WIDTH
    // Fixed-point normalization

    quantizer #(
        .WIDTH(WIDTH),
        .MODE(QMODE),
        .IS_ADD(1)
    )
    Q_ARBR (
        .din(arbr >>> (WIDTH-2)),
        .dout(sc_arbr)
    );

    quantizer #(
        .WIDTH(WIDTH),
        .MODE(QMODE),
        .IS_ADD(1)
    )
    Q_ARBI (
        .din(arbi >>> (WIDTH-2)),
        .dout(sc_arbi)
    );

    quantizer #(
        .WIDTH(WIDTH),
        .MODE(QMODE),
        .IS_ADD(1)
    )
    Q_AIBR (
        .din(aibr >>> (WIDTH-2)),
        .dout(sc_aibr)
    );

    quantizer #(
        .WIDTH(WIDTH),
        .MODE(QMODE),
        .IS_ADD(1)
    )
    Q_AIBI (
        .din(aibi >>> (WIDTH-2)),
        .dout(sc_aibi)
    );

    // COMPLEX ADD/SUB

    assign temp_re = sc_arbr - sc_aibi;
    assign temp_im = sc_arbi + sc_aibr;

    // FINAL OUTPUT QUANTIZATION

    quantizer #(
        .WIDTH(WIDTH),
        .MODE(QMODE),
        .IS_ADD(0)
    )
    Q_OUT_RE (
        .din(temp_re),
        .dout(m_re)
    );

    quantizer #(
        .WIDTH(WIDTH),
        .MODE(QMODE),
        .IS_ADD(1)
    )
    Q_OUT_IM (
        .din(temp_im),
        .dout(m_im)
    );

endmodule
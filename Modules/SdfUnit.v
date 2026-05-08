// SdfUnit
// Radix-2^2 Single-Path Delay Feedback Unit
// Independent Stage Quantization

module SdfUnit #(


    // STAGE A PARAMETERS

    parameter WIDTH_A = 16,
    parameter QMODE_A = 0,


    // STAGE B PARAMETERS

    parameter WIDTH_B = 16,
    parameter QMODE_B = 0,


    // DELAYS

    parameter DELAY1 = 16,
    parameter DELAY2 = 8

)(
    input clock,
    input reset,

    input di_en,

    input signed [WIDTH_A-1:0] di_re,
    input signed [WIDTH_A-1:0] di_im,

    output reg do_en,

    output reg signed [WIDTH_B-1:0] do_re,
    output reg signed [WIDTH_B-1:0] do_im
);

    // DELAY BUFFER 1

    wire signed [WIDTH_A-1:0] db1_re;
    wire signed [WIDTH_A-1:0] db1_im;

    DelayBuffer #(
        .DEPTH(DELAY1),
        .WIDTH(WIDTH_A)
    )
    DB1 (
        .clock(clock),

        .di_re(di_re),
        .di_im(di_im),

        .do_re(db1_re),
        .do_im(db1_im)
    );

    // BUTTERFLY 1

    wire signed [WIDTH_A-1:0] bf1_y0_re;
    wire signed [WIDTH_A-1:0] bf1_y0_im;

    wire signed [WIDTH_A-1:0] bf1_y1_re;
    wire signed [WIDTH_A-1:0] bf1_y1_im;

    Butterfly #(
        .WIDTH(WIDTH_A),
        .QMODE(QMODE_A)
    )
    BF1 (
        .x0_re(di_re),
        .x0_im(di_im),

        .x1_re(db1_re),
        .x1_im(db1_im),

        .y0_re(bf1_y0_re),
        .y0_im(bf1_y0_im),

        .y1_re(bf1_y1_re),
        .y1_im(bf1_y1_im)
    );


    // WIDTH CONVERSION

    wire signed [WIDTH_B-1:0] bf1_to_bf2_re;
    wire signed [WIDTH_B-1:0] bf1_to_bf2_im;

    assign bf1_to_bf2_re =
        bf1_y0_re[WIDTH_A-1 -: WIDTH_B];

    assign bf1_to_bf2_im =
        bf1_y0_im[WIDTH_A-1 -: WIDTH_B];

    // DELAY BUFFER 2

    wire signed [WIDTH_B-1:0] db2_re;
    wire signed [WIDTH_B-1:0] db2_im;

    DelayBuffer #(
        .DEPTH(DELAY2),
        .WIDTH(WIDTH_B)
    )
    DB2 (
        .clock(clock),

        .di_re(bf1_to_bf2_re),
        .di_im(bf1_to_bf2_im),

        .do_re(db2_re),
        .do_im(db2_im)
    );

    // BF1 SECOND OUTPUT WIDTH CONVERSION

    wire signed [WIDTH_B-1:0] bf1_y1_re_b;
    wire signed [WIDTH_B-1:0] bf1_y1_im_b;

    assign bf1_y1_re_b =
        bf1_y1_re[WIDTH_A-1 -: WIDTH_B];

    assign bf1_y1_im_b =
        bf1_y1_im[WIDTH_A-1 -: WIDTH_B];


    // BUTTERFLY 2

    wire signed [WIDTH_B-1:0] bf2_y0_re;
    wire signed [WIDTH_B-1:0] bf2_y0_im;

    wire signed [WIDTH_B-1:0] bf2_y1_re;
    wire signed [WIDTH_B-1:0] bf2_y1_im;

    Butterfly #(
        .WIDTH(WIDTH_B),
        .QMODE(QMODE_B)
    )
    BF2 (
        .x0_re(bf1_y1_re_b),
        .x0_im(bf1_y1_im_b),

        .x1_re(db2_re),
        .x1_im(db2_im),

        .y0_re(bf2_y0_re),
        .y0_im(bf2_y0_im),

        .y1_re(bf2_y1_re),
        .y1_im(bf2_y1_im)
    );

    // TWIDDLE

    reg [9:0] tw_addr;

    wire signed [WIDTH_B-1:0] tw_re;
    wire signed [WIDTH_B-1:0] tw_im;

    always @(posedge clock or posedge reset)
    begin

        if (reset)
            tw_addr <= 0;
        else if (di_en)
            tw_addr <= tw_addr + 1'b1;

    end

    Twiddle #(
        .WIDTH(WIDTH_B),
        .ADDR_WIDTH(10)
    )
    TW (
        .clock(clock),

        .addr(tw_addr),

        .tw_re(tw_re),
        .tw_im(tw_im)
    );


    // MULTIPLY

    wire signed [WIDTH_B-1:0] mu_re;
    wire signed [WIDTH_B-1:0] mu_im;

    Multiply #(
        .WIDTH(WIDTH_B),
        .QMODE(QMODE_B)
    )
    MU (
        .a_re(bf2_y0_re),
        .a_im(bf2_y0_im),

        .b_re(tw_re),
        .b_im(tw_im),

        .m_re(mu_re),
        .m_im(mu_im)
    );


    // OUTPUT REGISTERS

    always @(posedge clock or posedge reset)
    begin

        if (reset)
        begin

            do_en <= 0;

            do_re <= 0;
            do_im <= 0;

        end

        else
        begin

            do_en <= di_en;

            do_re <= mu_re;
            do_im <= mu_im;

        end

    end
endmodule
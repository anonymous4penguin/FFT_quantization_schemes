// FFT1024
// 1024-Point Radix-2^2 SDF FFT
// True 10-Stage Independent Optimization

module FFT1024 #(


    // WORDLENGTHS

    parameter W1  = 16,
    parameter W2  = 16,
    parameter W3  = 16,
    parameter W4  = 16,
    parameter W5  = 16,
    parameter W6  = 16,
    parameter W7  = 16,
    parameter W8  = 16,
    parameter W9  = 16,
    parameter W10 = 16,

    // QUANTIZATION MODES

    // 0 = BT
    // 1 = BR
    // 2 = HUB
    // 3 = THUB

    parameter Q1  = 0,
    parameter Q2  = 0,
    parameter Q3  = 0,
    parameter Q4  = 0,
    parameter Q5  = 0,
    parameter Q6  = 0,
    parameter Q7  = 0,
    parameter Q8  = 0,
    parameter Q9  = 0,
    parameter Q10 = 0

)(
    input clock,
    input reset,

    input di_en,

    input signed [W1-1:0] di_re,
    input signed [W1-1:0] di_im,

    output do_en,

    output signed [W10-1:0] do_re,
    output signed [W10-1:0] do_im
);

    // INTERMEDIATE SIGNALS

    wire su1_en;
    wire signed [W2-1:0] su1_re;
    wire signed [W2-1:0] su1_im;

    wire su2_en;
    wire signed [W4-1:0] su2_re;
    wire signed [W4-1:0] su2_im;

    wire su3_en;
    wire signed [W6-1:0] su3_re;
    wire signed [W6-1:0] su3_im;

    wire su4_en;
    wire signed [W8-1:0] su4_re;
    wire signed [W8-1:0] su4_im;


    // SDF UNIT 1
    // STAGES 1 & 2

    SdfUnit #(

        .WIDTH_A(W1),
        .QMODE_A(Q1),

        .WIDTH_B(W2),
        .QMODE_B(Q2),

        .DELAY1(512),
        .DELAY2(256)

    )
    SU1 (

        .clock(clock),
        .reset(reset),

        .di_en(di_en),

        .di_re(di_re),
        .di_im(di_im),

        .do_en(su1_en),

        .do_re(su1_re),
        .do_im(su1_im)

    );

    // SDF UNIT 2
    // STAGES 3 & 4

    SdfUnit #(

        .WIDTH_A(W3),
        .QMODE_A(Q3),

        .WIDTH_B(W4),
        .QMODE_B(Q4),

        .DELAY1(128),
        .DELAY2(64)

    )
    SU2 (

        .clock(clock),
        .reset(reset),

        .di_en(su1_en),

        .di_re(su1_re),
        .di_im(su1_im),

        .do_en(su2_en),

        .do_re(su2_re),
        .do_im(su2_im)

    );


    // SDF UNIT 3
    // STAGES 5 & 6

    SdfUnit #(

        .WIDTH_A(W5),
        .QMODE_A(Q5),

        .WIDTH_B(W6),
        .QMODE_B(Q6),

        .DELAY1(32),
        .DELAY2(16)

    )
    SU3 (

        .clock(clock),
        .reset(reset),

        .di_en(su2_en),

        .di_re(su2_re),
        .di_im(su2_im),

        .do_en(su3_en),

        .do_re(su3_re),
        .do_im(su3_im)

    );


    // SDF UNIT 4
    // STAGES 7 & 8

    SdfUnit #(

        .WIDTH_A(W7),
        .QMODE_A(Q7),

        .WIDTH_B(W8),
        .QMODE_B(Q8),

        .DELAY1(8),
        .DELAY2(4)

    )
    SU4 (

        .clock(clock),
        .reset(reset),

        .di_en(su3_en),

        .di_re(su3_re),
        .di_im(su3_im),

        .do_en(su4_en),

        .do_re(su4_re),
        .do_im(su4_im)

    );


    // SDF UNIT 5
    // STAGES 9 & 10

    SdfUnit #(

        .WIDTH_A(W9),
        .QMODE_A(Q9),

        .WIDTH_B(W10),
        .QMODE_B(Q10),

        .DELAY1(2),
        .DELAY2(1)

    )
    SU5 (

        .clock(clock),
        .reset(reset),

        .di_en(su4_en),

        .di_re(su4_re),
        .di_im(su4_im),

        .do_en(do_en),

        .do_re(do_re),
        .do_im(do_im)

    );

endmodule
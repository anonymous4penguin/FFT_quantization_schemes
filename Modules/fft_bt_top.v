// BT FFT Top

module fft_bt_top (

    input clock,
    input reset,

    input di_en,

    input signed [15:0] di_re,
    input signed [15:0] di_im,

    output do_en,

    output signed [15:0] do_re,
    output signed [15:0] do_im
);

FFT1024 #(

    .W1(16),
    .W2(16),
    .W3(16),
    .W4(16),
    .W5(16),
    .W6(16),
    .W7(16),
    .W8(16),
    .W9(16),
    .W10(16),

    .Q1(0),
    .Q2(0),
    .Q3(0),
    .Q4(0),
    .Q5(0),
    .Q6(0),
    .Q7(0),
    .Q8(0),
    .Q9(0),
    .Q10(0)

)
FFT_UUT (

    .clock(clock),
    .reset(reset),

    .di_en(di_en),

    .di_re(di_re),
    .di_im(di_im),

    .do_en(do_en),

    .do_re(do_re),
    .do_im(do_im)

);

endmodule
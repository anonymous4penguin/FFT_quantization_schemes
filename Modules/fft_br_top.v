// BR FFT Top

module fft_br_top (

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

    .Q1(1),
    .Q2(1),
    .Q3(1),
    .Q4(1),
    .Q5(1),
    .Q6(1),
    .Q7(1),
    .Q8(1),
    .Q9(1),
    .Q10(1)

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
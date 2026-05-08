// NSGA Optimized FFT Top

module fft_nsga_top (

    input clock,
    input reset,

    input di_en,

    input signed [15:0] di_re,
    input signed [15:0] di_im,

    output do_en,

    output signed [8:0] do_re,
    output signed [8:0] do_im
);

FFT1024 #(

    // WORDLENGTHS

    .W1(16),
    .W2(15),
    .W3(14),
    .W4(13),
    .W5(12),
    .W6(11),
    .W7(10),
    .W8(10),
    .W9(9),
    .W10(9),


    // QUANTIZATION MODES

    .Q1(3),
    .Q2(2),
    .Q3(2),
    .Q4(1),
    .Q5(1),
    .Q6(1),
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
// HUB FFT Top

module fft_hub_top (

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

    .Q1(2),
    .Q2(2),
    .Q3(2),
    .Q4(2),
    .Q5(2),
    .Q6(2),
    .Q7(2),
    .Q8(2),
    .Q9(2),
    .Q10(2)

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
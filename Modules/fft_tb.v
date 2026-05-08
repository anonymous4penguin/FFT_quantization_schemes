`timescale 1ns / 1ps

// FFT Testbench

`timescale 1ns / 1ps

module fft_tb;

    // CLOCK

    reg clock;

    initial
    begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    reg reset;

    // INPUTS

    reg di_en;

    reg signed [15:0] di_re;
    reg signed [15:0] di_im;


    // OUTPUTS

    wire do_en;

    wire signed [8:0] do_re;
    wire signed [8:0] do_im;

    fft_nsga_top DUT (

        .clock(clock),
        .reset(reset),

        .di_en(di_en),

        .di_re(di_re),
        .di_im(di_im),

        .do_en(do_en),

        .do_re(do_re),
        .do_im(do_im)

    );


    // INPUT STIMULUS

    integer i;

    initial
    begin

        // INITIALIZE


        reset = 1;

        di_en = 0;

        di_re = 0;
        di_im = 0;

        // RESET PERIOD

        #50;

        reset = 0;

        // ENABLE INPUT
        di_en = 1;
        // APPLY 1024 SAMPLES
        for (i=0; i<1024; i=i+1)
        begin

            @(posedge clock);
            // SIMPLE INPUT SIGNAL
            di_re <= i % 64;
            di_im <= 0;
        end


        // STOP INPUT

        @(posedge clock);
        di_en <= 0;
        di_re <= 0;
        di_im <= 0;


        // WAIT FOR PIPELINE
        #5000;
        $finish;
    end

    // OUTPUT MONITOR
    always @(posedge clock)
    begin

        if (do_en)
        begin

            $display(
                "TIME=%0t  OUT_RE=%d  OUT_IM=%d",
                $time,
                do_re,
                do_im
            );

        end

    end
endmodule

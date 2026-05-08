// DelayBuffer
// Single-Path Delay Feedback Memory

module DelayBuffer #(

    parameter DEPTH = 16,
    parameter WIDTH = 16

)(
    input clock,

    input signed [WIDTH-1:0] di_re,
    input signed [WIDTH-1:0] di_im,

    output signed [WIDTH-1:0] do_re,
    output signed [WIDTH-1:0] do_im
);

    // MEMORY ARRAYS

    reg signed [WIDTH-1:0] mem_re [0:DEPTH-1];
    reg signed [WIDTH-1:0] mem_im [0:DEPTH-1];


    // POINTER

    integer i;

    reg [$clog2(DEPTH)-1:0] ptr;


    // OUTPUTS

    assign do_re = mem_re[ptr];
    assign do_im = mem_im[ptr];

    // SHIFT MEMORY

    always @(posedge clock)
    begin

        mem_re[ptr] <= di_re;
        mem_im[ptr] <= di_im;

        if (ptr == DEPTH-1)
            ptr <= 0;
        else
            ptr <= ptr + 1'b1;

    end

    // INITIALIZATION

    initial
    begin

        ptr = 0;

        for (i=0; i<DEPTH; i=i+1)
        begin
            mem_re[i] = 0;
            mem_im[i] = 0;
        end

    end

endmodule
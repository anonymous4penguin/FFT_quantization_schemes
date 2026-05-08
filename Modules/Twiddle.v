// Twiddle
// Simplified Twiddle ROM

module Twiddle #(

    parameter WIDTH = 16,
    parameter ADDR_WIDTH = 10

)(
    input clock,

    input [ADDR_WIDTH-1:0] addr,

    output reg signed [WIDTH-1:0] tw_re,
    output reg signed [WIDTH-1:0] tw_im
);


    // SIMPLE TWIDDLE LUT
    // Fixed-point values
    // scaled by 2^(WIDTH-2)

    localparam SCALE = (1 << (WIDTH-2));

    always @(posedge clock)
    begin

        case(addr[3:0])

            // W0 = 1 + j0

            4'd0:
            begin
                tw_re <= SCALE;
                tw_im <= 0;
            end

            // 0.707 - j0.707

            4'd1:
            begin
                tw_re <= 11585;
                tw_im <= -11585;
            end

            // 0 - j1

            4'd2:
            begin
                tw_re <= 0;
                tw_im <= -SCALE;
            end

            // -0.707 - j0.707

            4'd3:
            begin
                tw_re <= -11585;
                tw_im <= -11585;
            end

            // -1 + j0

            4'd4:
            begin
                tw_re <= -SCALE;
                tw_im <= 0;
            end

            // -0.707 + j0.707

            4'd5:
            begin
                tw_re <= -11585;
                tw_im <= 11585;
            end

            // 0 + j1

            4'd6:
            begin
                tw_re <= 0;
                tw_im <= SCALE;
            end

            // 0.707 + j0.707

            4'd7:
            begin
                tw_re <= 11585;
                tw_im <= 11585;
            end

            // DEFAULT

            default:
            begin
                tw_re <= SCALE;
                tw_im <= 0;
            end

        endcase

    end
endmodule
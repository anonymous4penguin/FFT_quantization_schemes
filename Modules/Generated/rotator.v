// ======================================================
// ROTATOR TEMPLATE
// ======================================================

module rotator #(
    parameter WL = 16
)(
    input clk,

    input  signed [WL-1:0] xr,
    input  signed [WL-1:0] xi,

    output reg signed [WL-1:0] yr,
    output reg signed [WL-1:0] yi
);

// ======================================================
// CONSTANT TWIDDLE
// Example:
// W = 0.707 - j0.707
// ======================================================

localparam signed [WL-1:0] C = 16'sd181;
localparam signed [WL-1:0] S = -16'sd181;

// ======================================================
// MULTIPLIERS
// ======================================================

wire signed [2*WL-1:0] mult1;
wire signed [2*WL-1:0] mult2;

wire signed [2*WL-1:0] mult3;
wire signed [2*WL-1:0] mult4;

assign mult1 = xr * C;
assign mult2 = xi * S;

assign mult3 = xr * S;
assign mult4 = xi * C;

// ======================================================
// REAL / IMAG
// ======================================================

wire signed [2*WL:0] real_temp;
wire signed [2*WL:0] imag_temp;

assign real_temp = mult1 - mult2;
assign imag_temp = mult3 + mult4;

// ======================================================
// QUANTIZATION
// ======================================================

wire signed [WL-1:0] yr_comb;
wire signed [WL-1:0] yi_comb;

// ======================================================
// MODE-SPECIFIC QUANTIZATION
// ======================================================

generate

if ("HUB" == "BT") begin

    assign yr_comb = real_temp >>> (WL-2);
    assign yi_comb = imag_temp >>> (WL-2);

end

else if ("HUB" == "BR") begin

    assign yr_comb =
        (real_temp + (1 << (WL-3))) >>> (WL-2);

    assign yi_comb =
        (imag_temp + (1 << (WL-3))) >>> (WL-2);

end

else begin

    assign yr_comb =
        (real_temp + (1 << (WL-3))) >>> (WL-2);

    assign yi_comb =
        imag_temp >>> (WL-2);

end

endgenerate

// ======================================================
// REGISTER
// ======================================================

always @(posedge clk) begin

    yr <= yr_comb;
    yi <= yi_comb;

end

endmodule



// ======================================================
// TOP MODULE
// ======================================================

module top #(
    parameter WL = 16
)(
    input clk,

    input signed [WL-1:0] in1,
    input signed [WL-1:0] in2,

    output signed [WL-1:0] out_final
);

wire signed [WL-1:0] yr [0:15];
wire signed [WL-1:0] yi [0:15];

genvar i;

generate

    for (i=0; i<16; i=i+1) begin : GEN

        rotator #(.WL(WL)) r (

            .clk(clk),

            .xr(in1 + i),
            .xi(in2 + i),

            .yr(yr[i]),
            .yi(yi[i])

        );

    end

endgenerate

assign out_final =
    yr[0]  + yr[1]  +
    yr[2]  + yr[3]  +
    yr[4]  + yr[5]  +
    yr[6]  + yr[7]  +
    yr[8]  + yr[9]  +
    yr[10] + yr[11] +
    yr[12] + yr[13] +
    yr[14] + yr[15];

endmodule

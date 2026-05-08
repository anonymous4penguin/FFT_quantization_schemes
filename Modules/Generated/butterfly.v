// ======================================================
// BUTTERFLY TEMPLATE
// ======================================================

module butterfly #(
    parameter WL = 16
)(
    input clk,

    input  signed [WL-1:0] a_r,
    input  signed [WL-1:0] a_i,

    input  signed [WL-1:0] b_r,
    input  signed [WL-1:0] b_i,

    output reg signed [WL-1:0] out1_r,
    output reg signed [WL-1:0] out1_i,

    output reg signed [WL-1:0] out2_r,
    output reg signed [WL-1:0] out2_i
);

wire signed [WL:0] sum_r;
wire signed [WL:0] sum_i;

wire signed [WL:0] diff_r;
wire signed [WL:0] diff_i;

assign sum_r  = a_r + b_r;
assign sum_i  = a_i + b_i;

assign diff_r = a_r - b_r;
assign diff_i = a_i - b_i;

// ======================================================
// COMBINATIONAL OUTPUTS
// ======================================================

wire signed [WL-1:0] out1_r_comb;
wire signed [WL-1:0] out1_i_comb;

wire signed [WL-1:0] out2_r_comb;
wire signed [WL-1:0] out2_i_comb;

// ======================================================
// MODE LOGIC
// Injected from Python
// ======================================================


assign out1_r_comb = (sum_r + 1) >>> 1;
assign out1_i_comb = (sum_i + 1) >>> 1;
assign out2_r_comb = diff_r >>> 1;
assign out2_i_comb = diff_i >>> 1;


// ======================================================
// PIPELINE REGISTER
// ======================================================

always @(posedge clk) begin

    out1_r <= out1_r_comb;
    out1_i <= out1_i_comb;

    out2_r <= out2_r_comb;
    out2_i <= out2_i_comb;

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

wire signed [WL-1:0] o1_r [0:15];
wire signed [WL-1:0] o1_i [0:15];

wire signed [WL-1:0] o2_r [0:15];
wire signed [WL-1:0] o2_i [0:15];

genvar i;

generate

    for (i=0; i<16; i=i+1) begin : GEN

        butterfly #(.WL(WL)) b (

            .clk(clk),

            .a_r(in1 + i),
            .a_i(in2 + i),

            .b_r(in2 + i),
            .b_i(in1 + i),

            .out1_r(o1_r[i]),
            .out1_i(o1_i[i]),

            .out2_r(o2_r[i]),
            .out2_i(o2_i[i])

        );

    end

endgenerate

assign out_final =
    o1_r[0]  + o1_r[1]  +
    o1_r[2]  + o1_r[3]  +
    o1_r[4]  + o1_r[5]  +
    o1_r[6]  + o1_r[7]  +
    o1_r[8]  + o1_r[9]  +
    o1_r[10] + o1_r[11] +
    o1_r[12] + o1_r[13] +
    o1_r[14] + o1_r[15];

endmodule

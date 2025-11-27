`timescale 1ns / 1ps

module bp_top_tb;

reg clk;
reg reset;
wire [15:0] branches;
wire [15:0] correct;
wire [15:0] pht_correct;
wire [15:0] match_ctr;
wire [15:0] PC;
wire test_mode_o;
wire taken;
wire cur_prediction;

top_bp uut(
    .clk(clk),
    .reset(reset),
    .branches(branches),
    .correct(correct),
    .PC(PC),
    .taken(taken),
    .pht_correct(pht_correct),
    .test_mode_o(test_mode_o),
    .match_ctr(match_ctr),
    .cur_prediction(cur_prediction)
    );

initial
begin
clk = 0;
reset = 1;
#15
reset = 0;
end

always
#5 clk = ~clk;

endmodule

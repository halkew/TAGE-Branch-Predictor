`timescale 1ns / 1ps

module bp_top_tb;

reg clk;
reg reset;
wire [15:0] branches;
wire [15:0] correct;
wire [15:0] pht_correct;
wire [15:0] match_ctr;
wire [15:0] PC;
wire [63:0] GHR;
wire test_mode_o;
wire test_signal;
wire taken;
wire cur_prediction;
wire [15:0] test_sig_counter;

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
    .test_signal(test_signal),
    .GHR(GHR),
    .test_sig_counter(test_sig_counter),
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

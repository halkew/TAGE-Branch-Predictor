`timescale 1ns / 1ps

module base_pred_tb;

reg clk;
reg reset;
reg [7:0] PC;
reg br_ret;
reg br_dir;
wire prediction;


base_pred uut(
    .clk(clk),
    .reset(reset),
    .PC(PC),
    .br_ret(br_ret),
    .br_dir(br_dir),
    .prediction(prediction)
    );
    
    initial
    begin
    
    clk = 0;
    reset = 1;
    PC = 0;
    br_ret = 0;
    br_dir = 0;
    
    #15
    reset = 0;
    #10
    PC = 8'h02;
    br_ret = 1;
    br_dir = 1;
    #10
    br_ret = 0;
    #10
    br_ret = 1;
    #100
    br_ret = 0;
    #50
    PC = 8'h04; 
    
    end
    
    always
    #5 clk = ~clk;



endmodule

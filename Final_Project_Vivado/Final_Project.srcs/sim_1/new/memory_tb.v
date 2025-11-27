`timescale 1ns / 1ps
module memory_tb;

reg clk;
reg fetch;
wire [15:0] PC;
wire taken;

memory uut(
    .clk(clk),
    .fetch(fetch),
    .PC(PC),
    .taken(taken)
    );
    
    initial
    begin
        clk = 0;
        fetch = 0;
        
        #5
        
        fetch = 1;
        #10
        fetch = 0;
        #20
        fetch = 1;
        #20
        fetch = 0;
    end
    
    always
    #5 clk = ~clk;

endmodule

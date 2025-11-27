`timescale 1ns / 1ps

module var_mux_tb;

reg clk;
reg [3:0] predictions;
reg [2:0] selects;
wire pred;

var_mux #(.predictors(4)) uut(
    .predictions(predictions),
    .selects(selects),
    .pred(pred)
    );

initial
begin
    clk = 0;
    predictions = 4'b1010;
    //Should predict 0
    selects = 3'b010;
    #20
    //Should predict 1
    selects = 3'b111;
    #20
    //Should predict 0
    selects = 3'b000;
    #20
    //Should predict 1
    selects = 3'b110;
end

always
#5 clk = ~clk;


endmodule

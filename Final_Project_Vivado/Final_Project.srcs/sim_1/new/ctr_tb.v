`timescale 1ns / 1ps

module ctr_tb;

reg reset;
reg clk;
reg enable;
reg update;
reg alloc;
wire pred;

pred_ctr uut(
    .reset(reset),
    .clk(clk),
    .update(update), 
    .enable(enable),
    .alloc(alloc),
    .pred(pred)
    );
    
    
initial
begin
reset = 1;
clk = 0;
enable = 0;
update = 0;

#10
update = 1; //should be meaningless
#10
reset = 0;
enable = 1;
update = 1;
#90
update = 0;
#90
enable = 0;
update = 1;
alloc = 1;
#20
update = 0;
alloc = 1;
#20
alloc = 0;

end

always
#5 clk = ~clk;

endmodule

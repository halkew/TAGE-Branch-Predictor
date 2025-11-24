/*
This counter is used as a "useful counter" in the TAGE Branch Predictor
It is a simply 2 bit counter that gets initialized to 0 (strong not useful)
This counter saturates at the 2'b11 and 2'b00

If both the increment and decrement signals are both high, nothing will happen

Signals
- reset = active high synchronous reset
- clk = input clock from top module
- update = this is a single signal that determines if the counter is taking in a increment (1) or a decrement (0) command
- enable = this is a signal that determines if the counter is going to be incremented or decremented
           in combination with the update signal
- useful = a wire connecting to the MSB of the counter; determines if the value is useful

*/

module use_ctr(
    input reset,
    input clk,
    input update, 
    input enable,
    output useful
    );
    
    reg [1:0] ctr = 0;
    assign useful = ctr[1];
    
    always @ (posedge clk)
    begin
        if(reset)
        begin
            //Counter is reset on synchronous reset
            ctr <= 0;
        end
        else if(enable)
        begin
            if(update)
            begin
                if(ctr == 2'b11) ctr <= ctr;
                else ctr <= ctr + 1;
            end
            else if(!update)
            begin
                if(ctr == 2'b00) ctr <= ctr;
                else ctr <= ctr - 1;
            end
        end
    end
endmodule

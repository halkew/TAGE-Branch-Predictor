/*
This counter is used as a "prediction counter" in the TAGE Branch Predictor
It is a simply 3 bit counter that gets initialized to 0 (strong not useful)
However when it is allocated, it is initialized to weak correct
This counter saturates at the 3'b111 and 3'b000

If both the increment and decrement signals are both high, nothing will happen

Signals
- reset = active high synchronous reset
- clk = input clock from top module
- update = this is a single signal that determines if the counter is taking in a increment (1) or a decrement (0) command
- enable = this is a signal that determines if the counter is going to be incremented or decremented
           in combination with the update signal
- alloc = this signal allows the counter to be reset to a weak value based on the last taken branch
          when update == 1 -> ctr <= 3'b100
          when update == 0 -> ctr <= 3'b011
- useful = a wire connecting to the MSB of the counter; determines if the value is useful

*/

module pred_ctr(
    input reset,
    input clk,
    input update, 
    input enable,
    input alloc,
    output weak,
    output pred
    );
    
    reg [2:0] ctr = 0;
    assign pred = ctr[2];
    assign weak = (ctr == 3'b100) || (ctr == 3'b011);// ((ctr == 3'b000) || (ctr == 3'b111))
    
    always @ (posedge clk)
    begin
        if(reset)
        begin
            //Counter is reset on synchronous reset
            ctr <= 0;
        end
        else
        begin
            //Handles if it is being allocated
            if(alloc)
            begin
                //Needs to be set to weak, taken
                if(update)
                begin
                    ctr <= 3'b100;
                end
                //Needs to be set to weak, not taken
                else if (!update)
                begin
                    ctr <= 3'b011;
                end
            end
            //Makes sure there are nothing happens if inc and dec are both high
            else if(enable)
            begin
                if(update)
                //Increment Counter
                begin
                    if(ctr == 3'b111) ctr <= ctr;
                    else ctr <= ctr + 1;
                end
                else if(!update)
                //Decrement Counter
                begin
                    if(ctr == 3'b000) ctr <= ctr;
                    else ctr <= ctr - 1;
                end
            end
        end
    end
endmodule

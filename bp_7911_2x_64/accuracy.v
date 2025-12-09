/*
    The accuracy module is simply to check if the input prediction from the branch predictor is equivalent
    to the taken flag provided from memory
    
    It simply updates 2 counters, the branch_ctr, to indicate the number of branches, and the 
    correct_reg which displays how many of the branches were predicted correctly
    
    Signals
    - taken_i = input from the memory module that shows if the branch is supposed to be taken
    - clk = input clk from top module
    - check = should go high for one clock cycle to update the internal counters
    - prediction = the output of the branch predictor with the current PC
    - taken_o = the current taken output for the current PC
    - branches [2047:0] = the number of branches predicted so far
    - correct [2047:0] =  the number of correct predictions that have occurred

*/

module accuracy(
    input taken_i,
    input clk,
    input reset,
    input check,
    input prediction,
    input match,
    input test_mode,
    output taken_o,
    output [15:0] branches,
    output [15:0] correct, 
    output [15:0] pht_correct,
    output [15:0] match_ctr
    );
    
    reg [15:0] branch_ctr;
    reg [15:0] correct_reg;
    reg [15:0] pht_correct_reg;
    reg [15:0] match_ctr_reg;
    
    assign branches = branch_ctr;
    assign correct = correct_reg;
    assign pht_correct = pht_correct_reg;
    assign match_ctr = match_ctr_reg;
    
    assign taken_o = taken_i;
    
    wire compare = !(taken_i ^ prediction);
    
    always @ (posedge clk)
    begin
        if(reset)
        begin
            branch_ctr <= 0;
            correct_reg <= 0;
            pht_correct_reg <= 0;
            match_ctr_reg <= 0;
        end
        else if(check)
        begin
            if(test_mode)
            //Makes sure that accuracy is checked in the actual test
            begin
                //Check determines when the new instruction occurs
                branch_ctr <= branch_ctr + 1;
                //If the prediction and the answer for that PC are the same
                if(compare) correct_reg <= correct_reg + 1;
                if(compare && match) pht_correct_reg <= pht_correct_reg + 1;
                if(match) match_ctr_reg <= match_ctr_reg + 1;
            end
        end
    end
    
endmodule

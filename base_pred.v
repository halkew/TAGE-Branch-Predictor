
/*
This counter is the base counter for the branch predictor
This is a simple table that has prediction counters for each of the lower 8 bits of the PC (created using a generate block)

Signals
- reset = active high synchronous reset
- clk = input clock from top module
- PC[7:0] = lower 8 bits from the current PC
- br_ret = this signal goes high when a branch "retires" i.e we know if it was taken or not
- br_dir = this signal determines if the branch that was retired was taken (1) or not taken (0)
- prediction = the prediction of the base predictor based on the PC

*/

module base_pred #(parameter INDEX_LEN = 8)
    (
    input clk,
    input reset,
    input [7:0] PC,
    input br_ret,
    input br_dir,
    output prediction
    );
    
    
    wire [(2**INDEX_LEN) - 1:0] table_preds;
    
    reg [(2**INDEX_LEN) - 1:0] table_enable;
    
    assign prediction = table_preds[PC];
    
    always @ (posedge clk)
    begin
        if(reset)
        begin
            //On reset
            table_enable <= 0;
        end
        else
        begin
            //A branch is retired and the br_dir is valid
            if(br_ret)
            begin
                table_enable[PC] <= 1;
            end
            else
            begin
            //Might change this to be implemented on the negedge
                table_enable[PC] <= 0;
            end
        end
    end
    
    
    //Generating all the prediction counters for the base predictors
    genvar i;
    
    generate
        for(i = 0; i < (2**INDEX_LEN); i = i + 1) begin: base_gen
            //Each instance of a prediction counter
            pred_ctr p_i(
                .clk(clk),
                .reset(reset),
                .alloc(1'b0),
                .update(br_dir),
                .enable(table_enable[i]),
                .pred(table_preds[i])
            );
        end 
    endgenerate
    
    
    
endmodule

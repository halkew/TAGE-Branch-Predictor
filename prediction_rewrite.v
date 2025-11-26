// Taken_o -> asserted when the branch should be taken
// Match -> signal asserted from each PHT when a match is recieved
// Prediction -> signal asserted from each PHT with the propsed prediction
// Only observe the prediction where there is a match

//For the TOP module, make a 


module prediction_rewrite #(parameter PHT_COUNT = 3)
    (

    input reset,
    input clk,
    input [PHT_COUNT:0] prediction,
    input [PHT_COUNT:1] match,
    input [PHT_COUNT:1] can_alloc,
    input taken,
    input start,
    output reg check,
    output reg [PHT_COUNT:1] enable_use,
    output reg [PHT_COUNT:1] update_use,
    output reg [PHT_COUNT:1] alloc,
    output final_pred,
    output needs_alloc
    );




endmodule
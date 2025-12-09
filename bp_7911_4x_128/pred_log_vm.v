/*
State Explanation
+ 0 = initial state; 
    - Determine Provider 
    - Determine Alternate Provider
    - Determine the lowest order predictor (lop)
    - Check the current prediction
+ 1 = Update Predictors;
    - Update Prediction Counter of Provider Component
    - Allocate, if necessary to the lop
    - Update Usefulness Counter, if necessary, of the provider component
   
+ 2 = Finish Updating;
    - Set all update signals to be low
    - Reset any registers in the prediction logic
    - Fetch the new PC

+ 3 = Global State Update;
    - Retrieve the new PC
    - Update GHR
*/

module pred_logic_vm #(parameter PHT_COUNT = 3)
    (
    //Global variables
    input reset,
    input clk,
    input test_mode,
    //Inputs from predictors
    input [PHT_COUNT:0] prediction,
    input [PHT_COUNT:1] match,
    input [PHT_COUNT:1] can_alloc,
    input [PHT_COUNT:1] weak,
    //Accuracy Module Signals
    input taken,
    output reg check,
    //Outputs to PHTs
    output reg [PHT_COUNT:1] enable_use,
    output reg [PHT_COUNT:1] update_use,
    output reg [PHT_COUNT:0] br_ret,
    output reg [PHT_COUNT:0] br_dir,
    output reg [PHT_COUNT:1] alloc,
    //Global Output
    output final_pred,
    output [127:0] GHR,
    //Debugging Signal
    output reg needs_alloc,
    //Memory Signals
    output reg fetch
    );
    
    //Variable MUX generation with multiple predictors
    wire var_mux_pred;
    var_mux #(.predictors(4)) m1(.predictions(prediction),.selects(match),.pred(var_mux_pred));
    //Potentially make a variable, variable mux for this
    reg [127:0] GHR_reg = 0;
    assign GHR = GHR_reg;
//    assign final_pred = prediction[1];
    
    wire [$clog2(PHT_COUNT):0] provider_wire = (match[3] ? 2'b11 : (match[2] ? 2'b10: (match[1] ? 2'b01 : 2'b00))); //index of provider
    wire altpred1 = match[3] & match[2];
    wire altpred0 = (!match[3] & match[2] & match[1]) | (match[3] & !match[2] & match[1]);
    wire [1:0] altprovider_wire = {altpred1,altpred0};
    
    //If weak prediction counter and 0 useful counter alt pred (defined as newly allocated)
    assign final_pred = (weak[provider_wire] && can_alloc[provider_wire]) ? prediction[altprovider_wire]: prediction[provider_wire];
        
    reg [1:0] state;
    reg [$clog2(PHT_COUNT):0] lop = 0;
    wire matches = |(match); //if there are no matches it will be 0
    wire correct = !(taken ^ final_pred) && !reset; // If they are the same its correct
    wire open_alloc = |(alloc); //At any pht is there space to alloc

    wire diff_prov = altprovider_wire != provider_wire;//The alternate component and provider component will only be the same if there is no match
    wire inc_alloc = (provider_wire != PHT_COUNT); //&& (provider != 0); //needs to be allocated on incorrect; 
                                                                 // if the provider is not the longest history and its not the base pred
    
    always @ (posedge clk)
    begin
        if(reset)
        begin
            state <= 3;
            lop <= 0;
            enable_use <= 0;
            update_use <= 0;
            br_ret <= 0;
            br_dir <= 0;
            alloc <= 0;
            fetch <= 0;
            needs_alloc <= 0;
            GHR_reg <= 0;
        end
        else
        //State Machine
        begin
            case(state)
            0: //Initial State
            begin
                //Provider Determined Combinationally
                //Alternate Provider Determined Combinationally
                //determining lop logic
                if(provider_wire == 0) 
                begin
                    if(can_alloc[1]) lop <= 1;
                    else if(can_alloc[2]) lop <= 2;
                    else if(can_alloc[3] && !test_mode) lop <= 3;
                    else lop <= 0;
                end
                else if(provider_wire == 1) 
                begin
                    if(can_alloc[2]) lop <= 2;
                    else if(can_alloc[3] && !test_mode) lop <= 3;
                    else lop <= 0;
                end
                else if(provider_wire == 2) 
                begin
                    if(can_alloc[3] && !test_mode) lop <= 3;
                    else lop <= 0;
                end
                else lop <= 0;
                
                //Checking Prediction
                check <= 1;
                
                //Next State
                state <= 1;
            end
            1: //Update Predictors
            begin
            
                //Lower Previous Signals
                check <= 0;
                
                //Update Prediction Counter of the Provider Component
                br_ret[provider_wire] <= 1;
                br_dir[provider_wire] <= taken;
                
                //Allocate logic applies on incorrect situations only
                if(!correct && inc_alloc)
                begin
                    //Debugging Signal
                    needs_alloc <= 1;
                    //If there is even space to alloc
                    if(lop == 0)
                    begin
                        if (provider_wire == 2'b00) begin
                            enable_use[1] <= 1;
                            update_use[1] <= 0;
                            enable_use[2] <= 1;
                            update_use[2] <= 0;
                        end else if (provider_wire == 2'b01) begin
                            enable_use[2] <= 1;
                            update_use[2] <= 0;
                        end
                    end
                    else
                    //Space to alloc is found, allocate the lop
                    begin
                        alloc[lop] <= 1;
                        br_dir[lop] <= taken;
                    end
                end
                
                //Update the usefulness counter when the provider component and the alternate component are different
                 if(diff_prov && !(weak[provider_wire] && can_alloc[provider_wire]))
                 begin
                    enable_use[provider_wire] <= 1;
                    update_use[provider_wire] <= correct; //If correct, more useful, if not less useful
                 end
                 
                 
                 //Next State
                 state <= 2;
            
            end
            2: //Finish Updating
            begin
                //Lowering All Outputs that could have gone high on the last state
                br_ret <= 0;
                br_dir <= 0;
                enable_use <= 0;
                update_use <= 0;
                needs_alloc <= 0;
                alloc <= 0;
                
                //Raise the Fetch PC Flag
                fetch <= 1;
               
                
                //Next State
                state <= 3;
            end
            3: //Retrieve PC
            begin
                //Lower previous fetch signal
                fetch <= 0;
                
                //Update GHR
                GHR_reg <= {GHR[126:0],taken};
                
                //Next State 
                state <= 0;
            end
            default:
            begin
                state <= 3;
            end
            endcase
        end
    end

   

endmodule
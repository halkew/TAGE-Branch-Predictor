/*
State Explanation
- 0 = initial state; check flag goes high and alternate and provider components determined
      determines next state based on if the prediction was correct
- 1 = correct prediction;
- 2 = incorrect prediction;
- 3 = reset output state; ensures everything only goes high for 1 clock cycle
*/

module pred_logic_vm #(parameter PHT_COUNT = 3)
    (
    input reset,
    input clk,
    input [PHT_COUNT:0] prediction,
    input [PHT_COUNT:1] match,
    input [PHT_COUNT:1] can_alloc,
    input taken,
    output reg stall_bpi,
    output reg check,
    output reg [PHT_COUNT:1] enable_use,
    output reg [PHT_COUNT:1] update_use,
    output reg [PHT_COUNT:0] br_ret,
    output reg [PHT_COUNT:0] br_dir,
    output reg [PHT_COUNT:1] alloc,
    output final_pred,
    output reg needs_alloc
    );
    
    //Variable MUX generation with multiple predictors
    var_mux #(.predictors(4)) m1(.predictions(prediction),.selects(match),.pred(final_pred));
    


    reg [$clog2(PHT_COUNT):0] provider = 0;
    reg [$clog2(PHT_COUNT):0] altprovider = 0; //index of alternate
    reg [1:0] state;
    //reg [$clog2(PHT_COUNT):0] to_alloc;
    reg [$clog2(PHT_COUNT):0] lop = 0; //lowest open predictor
    
    wire no_match = |(match); //if there are no matches it will be 0
    wire correct = !(taken ^ final_pred) && !reset; // If they are the same its correct
    wire open_alloc = |(alloc); //At the current index there is a space to allocate
    wire diff_prov = altprovider != provider;//The alternate component and provider component will only be the same if there is no match
    wire inc_alloc = (provider != PHT_COUNT); //&& (provider != 0); //needs to be allocated on incorrect; 
                                                                 // if the provider is not the longest history and its not the base pred
    
      
    integer i;



    always @ (posedge clk)
    begin
        if (reset)
        begin
            altprovider <= 0;
            provider <= 0;
            state <= 0;
            //to_alloc <= 1;
            state <= 3;
            check <= 0;
            stall_bpi <= 0;
        end
        else 
        begin
            case (state)
            //Determines provider component and alternate component
            0: begin
                //If there are no matches, provider and alternate are both 0 or base pred
                if(!no_match)
                begin
                    // determine provider
                    for (i = 1; i < PHT_COUNT+1; i = i + 1) begin
                        if (match[i]) begin
                            provider <= i;
                        end
                    end
                    
                    
                    // determine alternate
                    for (i = 1; i < provider; i = i + 1) begin
                        if (match[i]) begin
                            altprovider <= i;
                        end
                    end
                    check <= 1; // raises check flag
                    stall_bpi <= 1;
                    
                end
                else
                begin
                    //Both provider and altprovider are the base predictor
                    provider <= 0;
                    altprovider <= 0;
                    stall_bpi <= 1;
                    check <= 1;
                end
                if(correct) state <= 1; //correct prediction
                else state <= 2; //incorrect prediction
            end
            1: //Correct Prediction
            begin  
                 check <= 0; //lowers check flag 
                 //If there are different providers, we need to update the useful counter of provider component
                 if(diff_prov)
                 begin
                    enable_use[provider] <= 1;
                    update_use[provider] <= 1;
                 end
                 
                 //update the prediction counter
                 br_ret[provider] <= 1;
                 br_dir[provider] <= 1;
                 state <= 3;
            end
            2: //Incorrect Prediction
            begin
                check <= 0; // lowers check flag 
                state <= 3;
                
                //decrementing provider component prediction counter
                br_ret[provider] <= 1;
                br_dir[provider] <= 0;

                
                //2 cases, an allocation needs to occur or not
                if(inc_alloc)
                //Allocation necessary
                begin
                    needs_alloc <= 1;
                    //Gets the lowest predictor that has space for allocation; If no predictor lop = 0
                    for (i = provider + 1; i < PHT_COUNT+1; i = i + 1) 
                    begin
                        if (can_alloc[i]) 
                        begin
                        if(lop == 0) lop <= i; // grabs the first instance where allocation can occur
                        end
                    end
                    
                    if(lop != 0)
                    //No greater predictor to allocate available
                    begin
                        //all intermediary predictors are decremented
                        for (i = provider + 1; i < PHT_COUNT; i = i + 1) 
                        begin
                            enable_use[i] <= 1;
                            update_use[i] <= 0;
                        end
                    end
                    else
                    //lowest predictor, greater than the provider found
                    //allocate the lop
                    begin
                        alloc[lop] <= 1;
                        br_dir[lop] <= taken;
                    end
                    
                end
                 //If there are different providers, we need to update the useful counter of provider component
                 if(diff_prov)
                 begin
                    enable_use[provider] <= 1;
                    update_use[provider] <= 0;
                 end
                

                state <= 3;
            end
            3: 
            begin 
                //Set outputs low
                br_ret <= 0;
                br_dir <= 0;
                enable_use <= 0;
                update_use <= 0;
                state <= 0;
                stall_bpi <= 0;
                alloc <= 0;
                needs_alloc <= 0;
                lop <= 0;
            end
            default: 
            //Default state
            begin
                state <= 3;
            end
            endcase
        end
    end

endmodule
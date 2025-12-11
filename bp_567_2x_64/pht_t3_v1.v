/*
    This is a module for a variable size PHT
    Everything should be adjusted with changes in params, with the exception of the folding of the tag and index
    
    Signals
    - reset = active high synchronous reset
    - clk = input clock from top module
    - GHR [63:0] = 64 bit global history register that holds the last 64 instances of branch history
    - PC [15:0] = 16 bit PC
    - alloc = this signal should go high in tandem with br_dir to signal an allocation occurring, 
        br_dir should be high if the correct branch prediction was taken
        br_dir should be low if the correct branch prediction was not taken
    - br_dir = this signal can go high with alloc or br_ret to indicate taken (1) vs not taken branch (0) 
               or increment (1) or decrement (0) of the prediction counter
    - br_ret = this signal should go high and indicates that the prediction counter is being updated based on the value of br_dir ( 1 - increment, 0- decrement)
    - enable_use = this signal goes high and indicates that the usefulness counter is being updated based on the value of update_use ( 1 - increment, 0 - decrement)
    - update_use = this signal determines if the usefulness counter is being incremented or decremented in conjunction with enable_use
    - can_alloc = output signal that shows that an allocation can occur at the current index
    - prediction = output signal of the current prediction at the current index
    - match = output signal if the calculated tag matches the tag value at the current index
*/


module pht_t3_v1 #(parameter INDEX_SIZE = 7, parameter TAG_SIZE = 7, parameter GHR_LEN = 64)
    (
    input reset,
    input clk,
    input [127:0] GHR,
    input [15:0] PC,
    input alloc,
    input br_dir,
    input br_ret,
    input msb_reset,
    input lsb_reset,
    input enable_use,
    input update_use,
    output can_alloc,
    output prediction,
    output weak,
    output match
    );
    
    wire [GHR_LEN - 1: 0] GHR_usable = GHR[GHR_LEN-1:0];
    
    //Manually change this shit if adjusting pht index or tag values
//    wire [INDEX_SIZE - 1:0] index = GHR_usable[3:0] ^ GHR_usable[9:4]  ^
//    GHR_usable[15:10] ^ GHR_usable[19:16] ^ GHR_usable[23:20] ^ GHR_usable[28:24] 
//    ^ GHR_usable[31:29] ^ GHR_usable[35:32] ^ GHR_usable[39:36] ^ GHR_usable[43:40]
//    ^ GHR_usable[47:44] ^ GHR_usable[51:48] ^ GHR_usable[55:52] ^ GHR_usable[59:56]
//    ^ GHR_usable[63:60] ^ PC[35:32];


    wire [6:0] folded_pc;
    folder_7b f3(.fold({48'b0,PC}),.folded(folded_pc));
//    wire [INDEX_SIZE - 1:0] index = 
//     folded_pc ^ GHR_usable[3:0] ^ GHR_usable[7:4] ^ GHR_usable[11:8] ^ GHR_usable[15:12]
//    ^GHR_usable[19:16] ^ GHR_usable[23:20] ^ GHR_usable[27:24] ^ GHR_usable[31:28]
//    ^GHR_usable[35:32] ^ GHR_usable[39:36] ^ GHR_usable[43:40] ^ GHR_usable[47:44]
//    ^GHR_usable[51:48] ^ GHR_usable[55:52] ^ GHR_usable[59:56] ^ GHR_usable[63:60];

                    
    wire [6:0] folded_ghr7;
//    wire [5:0] folded_ghr6;
    
    folder_7b_128 f1(.fold({64'b0,GHR_usable}),.folded(folded_ghr7));
//    folder_6b f2(.fold(GHR_usable),.folded(folded_ghr6));
    wire [INDEX_SIZE - 1:0] index = folded_pc ^ folded_ghr7;
    
    
//    wire [TAG_SIZE - 1:0] tag = PC[TAG_SIZE - 1:0] ^ folded_ghr7 ^ (folded_ghr6 << 1);
wire [TAG_SIZE - 1:0] tag = PC[TAG_SIZE - 1:0] ^ folded_ghr7 ^ ({folded_ghr7[5:0],folded_ghr7[6]});    
    //Pred Counter Control Regs
    wire [(2**INDEX_SIZE) - 1:0] pht_preds;
    wire [(2**INDEX_SIZE) - 1:0] pht_weaks;
    reg [(2**INDEX_SIZE) - 1:0] pht_enable;
    reg [(2**INDEX_SIZE) - 1:0] pht_alloc;
    
    //Useful Counter Control Regs
    wire [(2**INDEX_SIZE) - 1:0] pht_uses;
    reg [(2**INDEX_SIZE) - 1:0] pht_uses_enable;
    
    reg br_dir_reg = 0;
    reg update_use_reg = 0;
    
    //Tags
    reg [TAG_SIZE - 1:0] tag_vals [(2**INDEX_SIZE) - 1: 0];
    
    //Outputs
    assign can_alloc = (pht_uses[index] == 0) && !reset;
    assign prediction = (pht_preds[index]) && !reset;
    assign match = (tag_vals[index] == tag) && !reset;
    assign weak = pht_weaks[index];

    
    integer r_var;
    
    //Main Logic
    always @(posedge clk)
    begin
        if(reset)
        begin
            //Reset Handling
            pht_enable <= 0;
            pht_alloc <= 0;
            pht_uses_enable <= 0;
            //Reset the tag values:
            for(r_var = 0; r_var < (2**INDEX_SIZE); r_var = r_var + 1)
            begin
                tag_vals[r_var] <= 0; 
            end
        end
        else
        begin
            br_dir_reg <= br_dir; //Sync it up with the enable
            update_use_reg <= update_use; //sync it up with the enable
            //Prediction Counter is being updated
            if(br_ret) pht_enable[index] <= 1; 
            else pht_enable[index] <= 0; //Maintain 1 clock edge of updating
            //Useful Counter is being updated
            if(enable_use) pht_uses_enable[index] <= 1;
            else pht_uses_enable[index] <= 0; //Maintain 1 clock edge of updating
            //Allocation is ocurring
            if(alloc)
            begin
                pht_alloc[index] <= 1; 
                tag_vals[index] <= tag;
            end
            else pht_alloc[index] <= 0; //Maintain 1 clock edge of updating              
        end
    end
    
    
    //Prediction Counters Generation
    genvar i;
    
    generate
        for(i = 0; i < (2**INDEX_SIZE); i = i + 1) begin: pht_pred_gen
            //Each instance of a prediction counter
            pred_ctr p_i(
                .clk(clk),
                .reset(reset),
                .alloc(pht_alloc[i]),
                .update(br_dir_reg),
                .enable(pht_enable[i]),
                .weak(pht_weaks[i]),
                .pred(pht_preds[i])
            );
        end 
    endgenerate
    
    //Useful Counter Generation
    
    genvar j;
    
    generate
        for( j = 0; j < (2**INDEX_SIZE); j = j + 1) begin: pht_use_gen
            //Each instance of a usefulness counter
            use_ctr u_i(
                .clk(clk),
                .reset(pht_alloc[j]),
                .update(update_use_reg),
                .enable(pht_uses_enable[j]),
                .msb_reset(0),
                .lsb_reset(0),
                .useful(pht_uses[j])
            );
        end
    endgenerate
    
    
    
endmodule

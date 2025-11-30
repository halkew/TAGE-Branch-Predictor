module top_bp(
    input clk,
    input reset,
    output [15:0] branches,
    output [15:0] correct,
    output [15:0] pht_correct,
    output [15:0] match_ctr,
    output [15:0] PC,
    output [127:0] GHR,
    output test_signal,
    output taken,
    output reg [15:0] test_sig_counter, 
    output test_mode_o,
    output cur_prediction
    );
    
//Memory Module
wire fetch;
wire test_mode;
wire msb_reset;
wire lsb_reset;
assign test_mode_o = test_mode;
memory #(.test(60000),.warmup(30000)) mem_mod( .clk(clk), .fetch(fetch), 
    .PC(PC),.taken(taken), .reset(reset), .test_mode(test_mode),
    .msb_reset(msb_reset), .lsb_reset(lsb_reset));
                        
//Predictors -----------------------------------------------------------------------------------------------

//Base Predictor Module
wire base_prediction;
wire base_br_ret;
wire base_br_dir;
base_pred #(.INDEX_LEN(8)) base_pred_module
    (
    .clk(clk),
    .reset(reset),
    .PC(PC[7:0]),
    .br_ret(base_br_ret),
    .br_dir(base_br_dir),
    .prediction(base_prediction)
    );

//Pattern History Table 1
wire pht1_alloc;
wire pht1_br_ret;
wire pht1_br_dir;
wire pht1_enable_use;
wire pht1_update_use;
wire pht1_can_alloc;
wire pht1_prediction;
wire pht1_match;
wire pht1_weak;
pht_t1_v1 #(.INDEX_SIZE(5), .TAG_SIZE(5), .GHR_LEN(4)) pht_table1
    (
    .reset(reset),
    .clk(clk),
    .GHR(GHR),
    .PC(PC),
    .alloc(pht1_alloc),
    .br_dir(pht1_br_dir),
    .br_ret(pht1_br_ret),
    .enable_use(pht1_enable_use),
    .update_use(pht1_update_use),
    .can_alloc(pht1_can_alloc),
    .prediction(pht1_prediction),
    .msb_reset(msb_reset),
    .lsb_reset(lsb_reset),
    .weak(pht1_weak),
    .match(pht1_match)
    );

//Pattern History Table 2
wire pht2_alloc;
wire pht2_br_ret;
wire pht2_br_dir;
wire pht2_enable_use;
wire pht2_update_use;
wire pht2_can_alloc;
wire pht2_prediction;
wire pht2_match;
wire pht2_weak;
pht_t2_v1 #(.INDEX_SIZE(6), .TAG_SIZE(6), .GHR_LEN(16)) pht_table2
    (
    .reset(reset),
    .clk(clk),
    .GHR(GHR),
    .PC(PC),
    .alloc(pht2_alloc),
    .br_dir(pht2_br_dir),
    .br_ret(pht2_br_ret),
    .enable_use(pht2_enable_use),
    .update_use(pht2_update_use),
    .can_alloc(pht2_can_alloc),
    .prediction(pht2_prediction),
    .weak(pht2_weak),
    .msb_reset(msb_reset),
    .lsb_reset(lsb_reset),
    .match(pht2_match)
    );

//Pattern History Table 3
wire pht3_alloc;
wire pht3_br_ret;
wire pht3_br_dir;
wire pht3_enable_use;
wire pht3_update_use;
wire pht3_can_alloc;
wire pht3_prediction;
wire pht3_match;
wire pht3_weak;
pht_t3_v1 #(.INDEX_SIZE(7), .TAG_SIZE(7), .GHR_LEN(64)) pht_table3
    (
    .reset(reset),
    .clk(clk),
    .GHR(GHR),
    .PC(PC),
    .alloc(pht3_alloc),
    .br_dir(pht3_br_dir),
    .br_ret(pht3_br_ret),
    .enable_use(pht3_enable_use),
    .update_use(pht3_update_use),
    .can_alloc(pht3_can_alloc),
    .prediction(pht3_prediction),
    .msb_reset(msb_reset),
    .lsb_reset(lsb_reset),
    .weak(pht3_weak),
    .match(pht3_match)
    );

//Prediction Module
wire check_out;
wire final_pred;
assign cur_prediction = final_pred;
wire taken_o;
wire needs_alloc;
assign test_signal = needs_alloc && !(pht3_alloc || pht2_alloc || pht1_alloc);
    
pred_logic_vm #(.PHT_COUNT(3)) pred_logic
    (
    //Global variables
    .reset(reset),
    .clk(clk),
    .test_mode(test_mode),
    //Inputs from predictors
    .prediction({pht3_prediction,pht2_prediction,pht1_prediction,base_prediction}),
    .match({pht3_match,pht2_match,pht1_match}),
    .weak({pht3_weak,pht2_weak,pht1_weak}),
    .can_alloc({pht3_can_alloc,pht2_can_alloc,pht1_can_alloc}),
    //Accuracy Module Signals
    .taken(taken_o),
    .check(check_out),
    //Outputs to PHTs
    .enable_use({pht3_enable_use,pht2_enable_use,pht1_enable_use}),
    .update_use({pht3_update_use,pht2_update_use,pht1_update_use}),
    .br_ret({pht3_br_ret,pht2_br_ret,pht1_br_ret,base_br_ret}),
    .br_dir({pht3_br_dir,pht2_br_dir,pht1_br_dir,base_br_dir}),
    .alloc({pht3_alloc,pht2_alloc,pht1_alloc}),
    //Global Output
    .final_pred(final_pred),
    .GHR(GHR),
    //Debugging Signal
    .needs_alloc(needs_alloc),
    //Memory Signals
    .fetch(fetch)
    );

//Accuracy Module
accuracy acc_mod(
    .taken_i(taken),
    .clk(clk),
    .reset(reset),
    .check(check_out),
    .match(pht3_match | pht2_match | pht1_match),
    .prediction(final_pred),
    .taken_o(taken_o),
    .branches(branches),
    .correct(correct),
    .test_mode(test_mode),
    .pht_correct(pht_correct),
    .match_ctr(match_ctr)
    );

always @ (posedge clk)
begin
    if(reset) test_sig_counter <= 0;
    else if(test_signal) test_sig_counter <= test_sig_counter + 1;
end


    
endmodule

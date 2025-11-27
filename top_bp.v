module top_bp(
    input clk,
    input reset,
    output [15:0] branches,
    output [15:0] correct,
    output [15:0] pht_correct,
    output [15:0] match_ctr,
    output [15:0] PC,
    output taken,
    output test_mode_o,
    output cur_prediction
    );
    
//Memory Module
wire fetch;
wire test_mode;
assign test_mode_o = test_mode;
memory #(.test(60000),.warmup(30000)) mem_mod( .clk(clk), .fetch(fetch), .PC(PC),.taken(taken), .reset(reset), .test_mode(test_mode));

//Branch Predictor Interface Module
wire [15:0] bpi_PC;
wire br_ret;
wire br_dir;
wire [63:0] bpi_GHR;
wire pred_logic_stall_bpi;
wire pred_logic_alloc;
bpi branch_interface_mod(
.PC(PC),.taken_i(taken),
                        .reset(reset), .clk(clk), 
                        .fetch(fetch), .PC_o(bpi_PC),
                        .br_ret(br_ret), .br_dir(br_dir),
                        .ghr(bpi_GHR),.stall_bpi(pred_logic_stall_bpi),
                        .alloc(pred_logic_alloc));
                        
//Predictors -----------------------------------------------------------------------------------------------

//Base Predictor Module
wire base_prediction;
wire base_br_ret;
wire base_br_dir;
base_pred #(.INDEX_LEN(8)) base_pred_module
    (
    .clk(clk),
    .reset(reset),
    .PC(bpi_PC[7:0]),
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
pht_t1 #(.INDEX_SIZE(6), .TAG_SIZE(6), .GHR_LEN(4)) pht_table1
    (
    .reset(reset),
    .clk(clk),
    .GHR(bpi_GHR),
    .PC(bpi_PC),
    .alloc(pht1_alloc),
    .br_dir(pht1_br_dir),
    .br_ret(pht1_br_ret),
    .enable_use(pht1_enable_use),
    .update_use(pht1_update_use),
    .can_alloc(pht1_can_alloc),
    .prediction(pht1_prediction),
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
pht_t2 #(.INDEX_SIZE(5), .TAG_SIZE(5), .GHR_LEN(16)) pht_table2
    (
    .reset(reset),
    .clk(clk),
    .GHR(bpi_GHR),
    .PC(bpi_PC),
    .alloc(pht2_alloc),
    .br_dir(pht2_br_dir),
    .br_ret(pht2_br_ret),
    .enable_use(pht2_enable_use),
    .update_use(pht2_update_use),
    .can_alloc(pht2_can_alloc),
    .prediction(pht2_prediction),
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
pht_t3 #(.INDEX_SIZE(4), .TAG_SIZE(4), .GHR_LEN(64)) pht_table3
    (
    .reset(reset),
    .clk(clk),
    .GHR(bpi_GHR),
    .PC(bpi_PC),
    .alloc(pht3_alloc),
    .br_dir(pht3_br_dir),
    .br_ret(pht3_br_ret),
    .enable_use(pht3_enable_use),
    .update_use(pht3_update_use),
    .can_alloc(pht3_can_alloc),
    .prediction(pht3_prediction),
    .match(pht3_match)
    );

//Prediction Module
wire check_out;
wire final_pred;
assign cur_prediction = final_pred;
wire taken_o;

//Varun's Module
pred_logic_vm #(.PHT_COUNT(3)) pred_logic
    (
    .reset(reset),
    .clk(clk),
    .prediction({pht3_prediction,pht2_prediction,pht1_prediction,base_prediction}),
    .match({pht3_match,pht2_match,pht1_match}),
    .can_alloc({pht3_can_alloc,pht2_can_alloc,pht1_can_alloc}),
    .taken(taken_o),
    .stall_bpi(pred_logic_stall_bpi),
    .check(check_out),
    .enable_use({pht3_enable_use,pht2_enable_use,pht1_enable_use}),
    .update_use({pht3_update_use,pht2_update_use,pht1_update_use}),
    .br_ret({pht3_br_ret,pht2_br_ret,pht1_br_ret,base_br_ret}),
    .br_dir({pht3_br_dir,pht2_br_dir,pht1_br_dir,base_br_dir}),
    .alloc({pht3_alloc,pht2_alloc,pht1_alloc}),
    .final_pred(final_pred),
    .needs_alloc(pred_logic_alloc)
    );

//Alex Module
//prediction #(.PHT_COUNT(3)) pred_logic
//    (
//    .reset(reset),
//    .clk(clk),
//    .prediction({pht3_prediction,pht2_prediction,pht1_prediction,base_prediction}),
//    .match({pht3_match,pht2_match,pht1_match}),
//    .can_alloc({pht3_can_alloc,pht2_can_alloc,pht1_can_alloc}),
//    .taken(taken_o),
//    .stall_bpi(pred_logic_stall_bpi),
//    .check(check_out),
//    .enable_use({pht3_enable_use,pht2_enable_use,pht1_enable_use}),
//    .update_use({pht3_update_use,pht2_update_use,pht1_update_use}),
//    .alloc({pht3_alloc,pht2_alloc,pht1_alloc}),
//    .final_pred(final_pred),
//    .needs_alloc(pred_logic_alloc)
//    );

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




    
endmodule

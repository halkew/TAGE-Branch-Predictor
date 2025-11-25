module pht_tb;

reg clk;
reg reset;
reg [63:0] GHR;
reg [15:0] PC;
reg alloc;
reg br_dir;
reg br_ret;
reg enable_use;
reg update_use;
wire can_alloc;
wire prediction;
wire match;

initial begin
    clk = 0;
    reset = 0;
    GHR = 0;
    PC = 0;
    alloc = 0;
    br_dir = 0;
    br_ret = 0;
    enable_use = 0;
    update_use = 0;
    
    # 10 

    reset = 1;

    # 10
    
    reset = 0;
    GHR = 1;
    PC = 2;

    # 10

    alloc = 0;
    br_dir = 0;
    br_ret = 1;
    enable_use = 0;

    # 10
    
    alloc = 1;
    br_dir = 1;
    br_ret = 1;
    enable_use = 1;
    update_use = 0;

    # 10

    alloc = 0;
    br_dir = 0;
    br_ret = 1;
    enable_use = 1;
    update_use = 1;

    # 10

    GHR = 2;

    # 10

    alloc = 0;
    br_dir = 0;
    br_ret = 1;
    enable_use = 0;

    # 10
    
    alloc = 1;
    br_dir = 1;
    br_ret = 1;
    enable_use = 1;
    update_use = 0;

    # 10

    alloc = 0;
    br_dir = 0;
    br_ret = 1;
    enable_use = 1;
    update_use = 1;

    # 10

    PC = 3;

    # 10
    
    alloc = 0;
    br_dir = 0;
    br_ret = 1;
    enable_use = 0;

    # 10
    
    alloc = 1;
    br_dir = 1;
    br_ret = 1;
    enable_use = 1;
    update_use = 0;

    # 10

    alloc = 0;
    br_dir = 0;
    br_ret = 1;
    enable_use = 1;
    update_use = 1;

    # 10

    reset = 1;

end

always begin
    #5 clk = !clk;
end

pht pht1 (
    .clk(clk),
    .reset(reset),
    .GHR(GHR),
    .PC(PC),
    .alloc(alloc),
    .br_dir(br_dir),
    .br_ret(br_ret),
    .enable_use(enable_use),
    .update_use(update_use),
    .can_alloc(can_alloc),
    .prediction(prediction),
    .match(match)
);

endmodule
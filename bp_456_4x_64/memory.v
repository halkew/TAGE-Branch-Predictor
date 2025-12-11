/*
This is a simple memory module that utilizes a 16 bit PC and a 1 bit 
appended bit to represent if the branch is taken or not taken

Signals
- clk = input clock from the top module
- fetch = a fetch signal that is triggered on the negative edge to load a new value from memory
- PC = the PC of the loaded value
- taken = shows if the branch is supposed to be predicted as taken or not taken

*/

module memory #(parameter test = 5000, parameter warmup = 30000)(
    input clk,
    input fetch,
    input reset,
    output [15:0] PC,
    output reg test_mode,
    output reg msb_reset,
    output reg lsb_reset,
    output taken
    );

    reg [16:0] ROM_warmup [warmup:0];
    reg [16:0] ROM_test [test:0];
    reg [16:0] warmup_index = 0;
    reg [16:0] test_index = 0;
    reg [6:0] use_reset_msb = 0;
    reg msb = 1;
    reg branch_dur = 0;
    
//    assign msb_reset = msb && (use_reset_msb == 511);
//    assign lsb_reset = !msb && (use_reset_msb == 511);
    
    reg [16:0] branch;
    assign PC = branch[16:1];
    assign taken = branch[0];
    
    initial
    begin
        //Where the memory is being loaded in from
        $readmemb("30k_warmup1.mem",ROM_warmup);
        $readmemb("60k_test1.mem",ROM_test);
    end
    
    always @ (posedge clk)
    begin
        if(reset)
        begin
            msb_reset <= 0;
            lsb_reset <= 0;
            branch_dur <= 0;
        end
        else
        begin
            if(msb && (use_reset_msb == 127) && !branch_dur)
            begin
                branch_dur <= 1;
                msb_reset <= 1;
                lsb_reset <= 1;
            end
            else if(!msb && (use_reset_msb == 127) && !branch_dur)
            begin
                branch_dur <= 1;
                lsb_reset <= 1;
                msb_reset <= 1;
            end
            else
            begin
                msb_reset <= 0;
                lsb_reset <= 0;
            end
            if(fetch) branch_dur <= 0;
        end
    end
    
    always @(posedge clk)
    begin
        if(reset)
        begin
            test_index <= 0;
            warmup_index <= 0;
            branch <= ROM_warmup[warmup_index];
            test_mode <= 0;
            use_reset_msb <= 0;
            msb <= 1;
        end
        else if(fetch)
        begin
            
            use_reset_msb <= use_reset_msb + 1;
            if(use_reset_msb == 511) msb <= msb ^ 1;
            if(warmup_index < warmup)
            begin
                branch <= ROM_warmup[warmup_index];
                warmup_index <= warmup_index + 1;
                test_mode <= 0;
            end
            else
            begin
                branch <= ROM_test[test_index];
                test_index <= test_index + 1;
                test_mode <= 1;
            end

        end
    end
    

endmodule


/*module Memory(CS, WE, CLK, ADDR, Mem_Bus);
  input CS;
  input WE;
  input CLK;
  input [6:0] ADDR;
  inout [31:0] Mem_Bus;

  reg [31:0] data_out;
  reg [31:0] RAM [0:127];


  initial
  begin
    // Write your Verilog-Text IO code here 
    $readmemb("lab7p2b.mem",RAM);
  end

  assign Mem_Bus = ((CS == 1'b0) || (WE == 1'b1)) ? 32'bZ : data_out;

  always @(negedge CLK)
  begin

    if((CS == 1'b1) && (WE == 1'b1))
      RAM[ADDR] <= Mem_Bus[31:0];

    data_out <= RAM[ADDR];
  end
endmodule
*/
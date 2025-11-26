/*
This is a simple memory module that utilizes a 16 bit PC and a 1 bit 
appended bit to represent if the branch is taken or not taken

Signals
- clk = input clock from the top module
- fetch = a fetch signal that is triggered on the negative edge to load a new value from memory
- PC = the PC of the loaded value
- taken = shows if the branch is supposed to be predicted as taken or not taken

*/

module memory(
    input clk,
    input fetch,
    output [15:0] PC,
    output taken
    );

    reg [16:0] ROM [1200:0];
    reg [9:0] mem_index = 0;
    
    reg [16:0] branch;
    assign PC = branch[16:1];
    assign taken = branch[0];
    
    initial
    begin
        //Where the memory is being loaded in from
        $readmemb("ece382m_rom.mem",ROM);
    end
    
    always @(negedge clk)
    begin
        if(fetch)
        begin
            branch <= ROM[mem_index];
            mem_index <= mem_index + 1;
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
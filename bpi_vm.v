/*
    This module fetches the PC from memory and updates the GHR
    This module is in charge of the global state of the machine
    
    States
    - Update State; sets fetch high and then updates the GHR
    - Intermediate State: sets fetch low, sets pc_valid to go high
        Should not go back to update state until the stall_bpi is low
    
*/

module bpi_vm(
    input [15:0] PC,
    input taken_i,
    input reset,
    input clk,
    input alloc, //not used
    input stall_bpi,
    output fetch,
    output [15:0] PC_o,
    output reg br_ret, //not used
    output reg br_dir, //not used
    output reg [63:0] ghr,
    output pc_valid
);

assign PC_o = PC;
reg pc_valid_reg = 1;
reg fetch_reg = 0;
reg delay_reg = 0;
assign fetch = fetch_reg;
assign pc_valid = pc_valid_reg;

always @ (posedge clk)
begin
    if(reset)
    begin
        pc_valid_reg = 1    ;
        fetch_reg <= 0;
        delay_reg <= 0;
    end
    else
    begin
        if(delay_reg)
        begin
            fetch_reg <= 0;
            pc_valid_reg <= 1; //PC valid is set high
            delay_reg <= 0;
        end
        else if(stall_bpi == 0)
        //Update the global state of the machine
        begin
            ghr <= {ghr[62:0],taken_i}; //update the GHR
            fetch_reg <= 1; //Get the new PC
            delay_reg <= 1;
        end
    end
end










endmodule

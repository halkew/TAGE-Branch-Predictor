//Utilizes LFSR algo
//using: x⁸ + x⁶ + x⁵ + x⁴ + 1 as base polynomial
//Seed set to 8'b10110101 (completely arbitrary)

module rng(
    input [7:0] maxVal,
    input clk,
    output [7:0] randomVal
);

reg [7:0] seed = 8'b10110101;
reg feedback;

wire [7:0] randomVal;

always @(posedge clk) begin
    feedback <= (seed[7] ^ seed[5] ^ seed[4] ^ seed[3] ^ seed[0]);
    seed <= {feedback, seed[7:1]};
end

randomVal = (feedback % maxVal);

endmodule

// br_ret -> goes to base predictor and to PHTs
//States dictate when fetch signal is read and when accuracy is checked
//State 00: send fetch signal high
//State 01: PC is retrieved and send to the corresponding PHTs
//State 10: br_ret is set to high and br_dir is set to the taken_i value

module bpi(
    input [15:0] PC,
    input taken_i,
    input reset,
    input clk,
    input alloc,
    input stall_bpi,
    output fetch,
    output [15:0] PC_o,
    output br_ret,
    output br_dir,
    outputeg [63:0] ghr
);

    reg [1:0] state;
    reg [1:0] next_state;

    // state register
    always @ (posedge clk) begin
        if (reset) begin 
            fetch = 1'b0;
            PC_o = 16'b0;
            br_ret = 1'b0;
            br_dir = 1'b0;
            ghr = 64'b0;
            state <= 2'b00;
        end else begin
            state <= next_state;
        end
    end

    // next state logic
    always @(*) begin
        case (state)
            2'b00: next_state <= 2'b01;
            2'b01: next_state <= 2'b10;
            2'b10: begin
                next_state <= (stall_bpi) ? 2'b10 : 2'b00;
            end
            default: next_state <= 2'b00;
        endcase
    end

    // output logic
    always @(*) begin
        case (state)
            2'b00: begin
                fetch = 1'b1;
                br_ret = 1'b0;
                ghr = {ghr[62:0], taken_i};
                br_ret = 1'b0;
                br_dir = 1'b0;
            end
            2'b01: begin
                fetch = 1'b0;
                PC_o = PC;
            end
            2'b10: begin
                if (!alloc) begin
                    br_ret = 1'b1;
                    br_dir = taken_i;
                end else begin
                    br_ret = 1'b0;
                    br_dir = 1'b0;
                end
                
            end
        endcase
    end

endmodule
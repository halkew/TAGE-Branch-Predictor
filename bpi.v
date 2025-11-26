
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
    output reg fetch,
    output reg [15:0] PC_o,
    output reg br_ret,
    output reg br_dir,
    output reg [63:0] ghr
);

    // reg [15:0] PC_o;
    // reg fetch, br_ret, br_dir;

    reg [1:0] state;
    reg [1:0] next_state;

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

    always @(posedge clk) begin
        if (reset) begin
            fetch <= 1'b0;
            PC_o <= 16'b0;
            br_ret <= 1'b0;
            br_dir <= 1'b0;
            ghr <= 64'b0;
        end

        else begin
            case (state)
                2'b00: begin
                    fetch <= 1'b1;
                    br_ret <= 1'b0;
                    ghr <= {ghr[62:0], taken_i};
                    br_ret <= 1'b0;
                    br_dir <= 1'b0;
                end
                2'b01: begin
                    fetch <= 1'b0;
                    PC_o <= PC;
                end
                2'b10: begin
                    if (!alloc) begin
                        br_ret <= 1'b1;
                        br_dir <= taken_i;
                    end else begin
                        br_ret <= 1'b0;
                        br_dir <= 1'b0;
                    end
                    
                end
            endcase
        end
    end

endmodule
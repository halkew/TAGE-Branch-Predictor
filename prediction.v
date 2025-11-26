module prediction #(parameter PHT_COUNT = 3)
    (
    input reset,
    input clk,
    input [PHT_COUNT:0] prediction,
    input [PHT_COUNT:1] match,
    input [PHT_COUNT:1] can_alloc,
    input taken,
    output reg check,
    output reg [PHT_COUNT:1] enable_use,
    output reg [PHT_COUNT:1] update_use,
    output reg [PHT_COUNT:1] alloc,
    output final_pred
    );

    wire [$clog2(PHT_COUNT):0] pred = (match[3] ? 3 : (match[2] ? 2: (match[1] ? 1 : 0))); //index of provider
    reg [$clog2(PHT_COUNT):0] altpred; //index of alternate
    reg [1:0] state;
    reg [$clog2(PHT_COUNT):0] to_alloc;
    reg needs_alloc;

    integer i;

    assign final_pred = prediction[pred] >> 2;

    always @ (posedge clk)
    begin
        if (reset)
        begin
            altpred <= 0;
            state <= 0;
            to_alloc <= 1;
            check <= 0;
        end
        else 
        begin
            case (state)
            0: begin

                // determine alternate
                for (i = 1; i < pred; i = i + 1) begin
                    if (match[i]) begin
                        altpred <= i;
                    end
                end
                check <= 1; // raises check flag

                state <= 2;
            end
            // 1: begin // raises check flag 
            //     check <= 1;
            //     state <= 2;
            // end
            2: begin
                check <= 0; // lowers check flag 

                if (prediction[altpred] >> 2 != prediction[pred] >> 2) begin // different provider and alternate predictions
                    if (taken == 1) begin // correct
                        enable_use[pred] <= 1;
                        update_use[pred] <= 1;
                    end else begin // wrong
                        enable_use[pred] <= 1;
                        update_use[pred] <= 0;

                        for (i = PHT_COUNT; i < pred; i = i - 1) begin // checking PHTs greater than pred
                            if (can_alloc[i]) begin // sets alloc of next lowest pht number and then breaks
                                to_alloc <= i;
                                needs_alloc <= 1;
                            end
                        end
                    end
                end

                state <= 3;
            end
            3: begin // reinit and send alloc
                altpred <= 0;
                enable_use[pred] <= 0;
                to_alloc <= 1;
                needs_alloc <= 0;
                if (needs_alloc) begin
                    alloc[to_alloc] <= 1;
                end

                state <= 0;
            end
            default: begin
                state <= 0;
            end
            endcase
        end
    end

endmodule
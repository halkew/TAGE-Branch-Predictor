module prediction #(parameter PHT_COUNT = 3)
    (
    input reset,
    input clk,
    input [PHT_COUNT:0] prediction,
    input [PHT_COUNT:1] match,
    input [PHT_COUNT:1] can_alloc,
    input acc_done,
    input acc_result,
    output reg [PHT_COUNT:1] enable_use,
    output reg [PHT_COUNT:1] update_use,
    output reg [PHT_COUNT:1] alloc,
    output final_pred
    );

    reg [$clog2(PHT_COUNT):0] pred; //index of provider
    reg [$clog2(PHT_COUNT):0] altpred; //index of alternate
    reg [1:0] state;

    integer i;

    assign final_pred = prediction[pred] >> 2;

    always @ (posedge clk)
    begin
        if (reset)
        begin
            pred <= 0;
            altpred <= 0;
            state <= 0;
        end
        else 
        begin
            case (state)
            0: begin
                enable_use[pred] <= 0;

                // determine provider and alternate
                for (i = PHT_COUNT; i > 0; i = i - 1) begin
                    if (match[i]) begin
                        pred <= i;
                        break;
                    end else begin
                        pred <= 0;
                    end
                end

                // determine alternate
                for (i = pred - 1; i >= 0; i = i - 1) begin
                    if (i > 0) begin
                        if (match[i]) begin
                            altpred <= i;
                            break;
                        end
                    end else begin
                        altpred <= 0;
                    end
                end

                state <= 1;
            end
            1: begin // stall until accuracy checker is done
                state <= (acc_done) ? 2 : 1;
            end
            2: begin
                if (prediction[altpred] >> 2 != prediction[pred][2] >> 2) begin // different provider and alternate predictions
                    if (acc_result == 1) begin // correct
                        enable_use[pred] <= 1;
                        update_use[pred] <= 1;
                    end else begin // wrong
                        enable_use[pred] <= 1;
                        update_use[pred] <= 0;

                        for (i = pred; i < PHT_COUNT; i = i + 1) begin // checking PHTs greater than pred
                            if (can_alloc[i]) begin // sets alloc of next lowest pht number and then breaks
                                alloc[i] <= 0;
                                break;
                            end
                        end
                    end
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
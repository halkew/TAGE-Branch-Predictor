/*
 The number of predictors includes the base predictor
 PHT 0 equivalent to the base_predictor
*/

module var_mux #(parameter predictors = 4)(
    input [predictors - 1: 0] predictions,
    input [predictors - 2: 0] selects,
    output pred
    );
    
    genvar i;
    
    wire [predictors - 2: 0] mux_outs; //4 predictors and 3 MUXes but 4 mux outs, 
    assign pred = mux_outs[predictors - 2];
    
    generate
        for(i = 0; i < predictors - 1; i = i + 1) begin: base_gen
            if(i == 0)
            begin
            //for the case of the first MUX where the inputs is the bas predictor
            mux mux_i(
                .A(predictions[i]),
                .B(predictions[i + 1]),
                .sel(selects[i]),
                .out(mux_outs[i])
                );    
            end
            else
            begin
            //All other cases
            mux mux_i(
                .A(mux_outs[i-1]),
                .B(predictions[i + 1]),
                .sel(selects[i]),
                .out(mux_outs[i])
                ); 
            end
        end 
    endgenerate
endmodule

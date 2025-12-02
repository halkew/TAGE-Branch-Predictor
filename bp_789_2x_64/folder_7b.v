module folder_7b(
    input [63:0] fold,
    output [6:0] folded
);

    assign folded = fold[6:0] ^ fold[13:7] ^ fold[20:14] ^ fold[27:21] ^
                    fold[34:28] ^ fold[41:35] ^ fold[48:42] ^ fold[55:49] ^
                    fold[62:56] ^ {6'b0, fold[63]};

endmodule
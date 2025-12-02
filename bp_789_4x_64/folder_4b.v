module folder_4b(
    input [63:0] fold,
    output [3:0] folded
);

    assign folded = fold[3:0] ^ fold[7:4] ^ fold[11:8] ^ fold[15:12] ^
                    fold[19:16] ^ fold[23:20] ^ fold[27:24] ^ fold[31:28] ^
                    fold[35:32] ^ fold[39:36] ^ fold[43:40] ^ fold[47:44] ^
                    fold[51:48] ^ fold[55:52] ^ fold[59:56] ^ fold[63:60];

endmodule
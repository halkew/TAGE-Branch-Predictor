module folder_6b(
    input [63:0] fold,
    output [5:0] folded
);

    assign folded = fold[5:0] ^ fold[11:6] ^ fold[17:12] ^ fold[23:18] ^
                    fold[29:24] ^ fold[35:30] ^ fold[41:36] ^ fold[47:42] ^
                    fold[53:48] ^ fold[59:54] ^ {2'b0, fold[63:60]};

endmodule
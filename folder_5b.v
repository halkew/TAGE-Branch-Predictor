module folder_5b(
    input [63:0] fold,
    output [4:0] folded
);

    assign folded = fold[4:0] ^ fold[9:5] ^ fold[14:10] ^ fold[19:15] ^
                    fold[24:20] ^ fold[29:25] ^ fold[34:30] ^ fold[39:35] ^
                    fold[44:40] ^ fold[49:45] ^ fold[54:50] ^ fold[59:55] ^
                    {1'b0, fold[63:60]};

endmodule
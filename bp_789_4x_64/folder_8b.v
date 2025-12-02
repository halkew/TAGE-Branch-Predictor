module folder_8b(
    input [63:0] fold,
    output [7:0] folded
);

    assign folded = fold[7:0] ^ fold[15:8] ^ fold[23:16] ^ fold[31:24] ^
                    fold[39:32] ^ fold[47:40] ^ fold[55:48] ^ fold[63:56];

endmodule
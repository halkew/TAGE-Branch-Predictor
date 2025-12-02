module folder_8b_128(
    input  [127:0] fold,
    output [7:0]   folded
);

    assign folded = fold[7:0]     ^ fold[15:8]    ^ fold[23:16]   ^ fold[31:24]  ^
                    fold[39:32]   ^ fold[47:40]   ^ fold[55:48]   ^ fold[63:56]  ^
                    fold[71:64]   ^ fold[79:72]   ^ fold[87:80]   ^ fold[95:88]  ^
                    fold[103:96]  ^ fold[111:104] ^ fold[119:112] ^ fold[127:120];

endmodule
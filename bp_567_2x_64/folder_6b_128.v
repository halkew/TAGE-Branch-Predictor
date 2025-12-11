module folder_6b_128(
    input  [127:0] fold,
    output [5:0]   folded
);

    assign folded = fold[5:0]     ^ fold[11:6]    ^ fold[17:12]   ^ fold[23:18]   ^
                    fold[29:24]   ^ fold[35:30]   ^ fold[41:36]   ^ fold[47:42]   ^
                    fold[53:48]   ^ fold[59:54]   ^ fold[65:60]   ^ fold[71:66]   ^
                    fold[77:72]   ^ fold[83:78]   ^ fold[89:84]   ^ fold[95:90]   ^
                    fold[101:96]  ^ fold[107:102] ^ fold[113:108] ^ fold[119:114] ^
                    fold[125:120] ^ fold[127:126];

endmodule
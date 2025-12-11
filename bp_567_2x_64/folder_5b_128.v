module folder_5b_128(
    input  [127:0] fold,
    output [4:0]   folded
);

    assign folded = fold[4:0]     ^ fold[9:5]     ^ fold[14:10]   ^ fold[19:15]   ^
                    fold[24:20]   ^ fold[29:25]   ^ fold[34:30]   ^ fold[39:35]   ^
                    fold[44:40]   ^ fold[49:45]   ^ fold[54:50]   ^ fold[59:55]   ^
                    fold[64:60]   ^ fold[69:65]   ^ fold[74:70]   ^ fold[79:75]   ^
                    fold[84:80]   ^ fold[89:85]   ^ fold[94:90]   ^ fold[99:95]   ^
                    fold[104:100] ^ fold[109:105] ^ fold[114:110] ^ fold[119:115] ^
                    fold[124:120] ^ fold[127:125];

endmodule
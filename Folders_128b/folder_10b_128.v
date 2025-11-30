module folder_10b_128(
    input  [127:0] fold,
    output [9:0]   folded
);

    assign folded = fold[9:0]      ^ fold[19:10]     ^ fold[29:20]     ^
                    fold[39:30]    ^ fold[49:40]     ^ fold[59:50]     ^
                    fold[69:60]    ^ fold[79:70]     ^ fold[89:80]     ^
                    fold[99:90]    ^ fold[109:100]   ^ fold[119:110]   ^
                    fold[127:120];

endmodule
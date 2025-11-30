module folder_11b_128(
    input  [127:0] fold,
    output [10:0]  folded
);

    assign folded = fold[10:0]      ^ fold[21:11]      ^ fold[32:22]      ^
                    fold[43:33]      ^ fold[54:44]      ^ fold[65:55]      ^
                    fold[76:66]      ^ fold[87:77]      ^ fold[98:88]      ^
                    fold[109:99]     ^ fold[120:110]    ^
                    fold[127:121];

endmodule
module folder_7b_128(
    input  [127:0] fold,
    output [6:0]   folded
);

    assign folded = fold[6:0]      ^ fold[13:7]     ^ fold[20:14]    ^
                    fold[27:21]    ^ fold[34:28]    ^ fold[41:35]    ^
                    fold[48:42]    ^ fold[55:49]    ^ fold[62:56]    ^
                    fold[69:63]    ^ fold[76:70]    ^ fold[83:77]    ^
                    fold[90:84]    ^ fold[97:91]    ^ fold[104:98]   ^
                    fold[111:105]  ^ fold[118:112]  ^ fold[125:119]  ^
                    fold[127:126];

endmodule
module folder_9b_128(
    input  [127:0] fold,
    output [8:0]   folded
);

    assign folded = fold[8:0]      ^ fold[17:9]      ^ fold[26:18]    ^
                    fold[35:27]    ^ fold[44:36]     ^ fold[53:45]    ^
                    fold[62:54]    ^ fold[71:63]     ^ fold[80:72]    ^
                    fold[89:81]    ^ fold[98:90]     ^ fold[107:99]   ^
                    fold[116:108]  ^ fold[125:117]   ^
                    fold[127:126];

endmodule
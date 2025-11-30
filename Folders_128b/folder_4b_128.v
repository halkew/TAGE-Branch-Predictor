module folder_4b_128( 
    input  [127:0] fold,
    output [3:0]   folded
);

    assign folded = fold[3:0]    ^ fold[7:4]    ^ fold[11:8]   ^ fold[15:12]  ^
                    fold[19:16]  ^ fold[23:20]  ^ fold[27:24]  ^ fold[31:28]  ^
                    fold[35:32]  ^ fold[39:36]  ^ fold[43:40]  ^ fold[47:44]  ^
                    fold[51:48]  ^ fold[55:52]  ^ fold[59:56]  ^ fold[63:60]  ^
                    fold[67:64]  ^ fold[71:68]  ^ fold[75:72]  ^ fold[79:76]  ^
                    fold[83:80]  ^ fold[87:84]  ^ fold[91:88]  ^ fold[95:92]  ^
                    fold[99:96]  ^ fold[103:100]^ fold[107:104]^ fold[111:108]^
                    fold[115:112]^ fold[119:116]^ fold[123:120]^ fold[127:124];

endmodule
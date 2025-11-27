module folder_3b(
    input [63:0] fold,
    output [2:0] folded
);

assign folded =
      fold[2:0]   ^ fold[5:3]   ^ fold[8:6]   ^ fold[11:9]  ^
      fold[14:12] ^ fold[17:15] ^ fold[20:18] ^ fold[23:21] ^
      fold[26:24] ^ fold[29:27] ^ fold[32:30] ^ fold[35:33] ^
      fold[38:36] ^ fold[41:39] ^ fold[44:42] ^ fold[47:45] ^
      fold[50:48] ^ fold[53:51] ^ fold[56:54] ^ fold[59:57] ^
      fold[62:60] ^ fold[63];

endmodule
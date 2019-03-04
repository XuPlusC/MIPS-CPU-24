/*
**  作者：林力韬
**  功能：地址映射
**  原创
*/

//地址映射遵照第二届龙芯杯地址划分标准(doc/A03文件)
module addr_map( 
    input   [31:0] addr_in,
    output  [31:0] addr_out
);

    assign addr_out = (addr_in[31:30]==2'b11)? addr_in 				:		// 0xC0000000~0xFFFFFFFF 不变
					  (addr_in[31:30]==2'b10)? {3'b0,addr_in[28:0]} :		// 0xBFFFFFFF => 0x1FFFFFFF, 0x80000000 => 0x00000000
					  (addr_in[31]==0)		 ? addr_in				:32'h0;	// 0x00000000~0x7FFFFFFF 不变

endmodule

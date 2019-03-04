/*
**	作者：张鑫
**	功能：load-use冲突检测，生成气泡信号
**	原创
*/

module special_pop (
	input [2:0]			load_store,
	input [31:0]		alu_r1_ex,
	input 				not_nop_mem,
	output 				special_pop
);
	
	
	assign special_pop = (&load_store) && ((alu_r1_ex==32'hfffffff8)||(alu_r1_ex==32'hfffffffc)) && not_nop_mem;

endmodule
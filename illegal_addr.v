/*
**	作者：张鑫
**	功能：数据RAM地址异常检测
**	原创
*/
module illegal_addr (
	input [2:0]			load_store_mem,
	input [1:0]			data_sram_addr_byte,
	
	output reg 			dm_addr_illegal
);
	
	always @(*) begin
		case(load_store_mem)
			3'b010,3'b011,3'b110: begin	//lh,lhu,sh
				dm_addr_illegal <= data_sram_addr_byte[0];
			end
			3'b100,3'b111: begin	//lw,sw
				dm_addr_illegal <= data_sram_addr_byte[1] | data_sram_addr_byte[0];
			end
			default: begin
				dm_addr_illegal <= 1'b0;
			end
		endcase
	end // always @(*)
	
endmodule
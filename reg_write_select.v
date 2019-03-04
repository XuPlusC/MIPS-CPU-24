/*
**	作者：张鑫
**	功能：写寄存器编号选择
**	原创
*/
module reg_write_select(
	input 		[4:0]		rt_id,
	input 		[4:0]		rd_id,
	input 		[1:0]		rw_sel_id,
	output reg	[4:0]		rw
);

	always @(*) begin
		case(rw_sel_id)
			2'b00:begin
				rw <= 5'b11111;
			end // 2'b00:
			2'b01: begin
				rw <= rt_id;
			end // 2'b01:
			2'b10: begin
				rw <= rd_id;
			end // 2'b10:
			default: rw <= 5'b11111;
		endcase
	end
	
endmodule

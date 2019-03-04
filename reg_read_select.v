/*
**	作�?�：张鑫
**	功能：读寄存器编号�?�择
**	原创
*/
module reg_read_select(
	input 		[4:0]		rs_id,
	input 		[4:0]		rt_id,
	input 					r1_sel_id,
	input 					r2_sel_id,
	output reg	[4:0]		r1,
	output reg	[4:0]		r2
);
	

	always @* begin
		case(r1_sel_id)
			1'b0: begin
				r1 <= rs_id;
			end // 2'b00:
			1'b1: begin
				r1 <= rt_id;
			end // 2'b01:
			default: r1 <= r1;
		endcase
	end

	always @* begin
		case(r2_sel_id)
			1'b0: begin
				r2 <= rs_id;
			end // 2'b00:
			1'b1: begin
				r2 <= rt_id;
			end // 2'b01:
			default: r2 <= r2;
		endcase
	end
	
endmodule

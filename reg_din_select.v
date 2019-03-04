/*
**	作者：张鑫
**	功能：通用寄存器写入的数据选择
**	原创
*/
module reg_din_select(
	input 		[31:0]			alu_r_wb,
	input 		[31:0]			pc_wb,
	input 		[31:0]			DMout_wb,
	input 		[31:0]			cp0_d1_wb,
	input 		[31:0]			HI_wb,
	input 		[31:0]			LO_wb,
	input 		[2:0]			reg_din_sel,
	
	output reg	[31:0]			reg_din
);

	always @(*) begin
		case(reg_din_sel)
			3'b110: begin
				reg_din <= alu_r_wb;
			end // 3'b000:
			3'b001: begin
				reg_din <= pc_wb + 8;
			end // 3'b001:
			3'b010: begin
				reg_din <= DMout_wb;
			end // 3'b010:
			3'b011: begin
				reg_din <= cp0_d1_wb;
			end // 3'b011:
			3'b100: begin
				reg_din <= HI_wb;
			end // 3'b100:
			3'b101: begin
				reg_din <= LO_wb;
			end // 3'b101:
			default: begin
				reg_din <= 32'h0;
			end // default:
		endcase // reg_din_sel
	end // always @(*)
	
endmodule
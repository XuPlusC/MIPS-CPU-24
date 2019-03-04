/*
**	作者：张鑫
**	功能：对数据进行无符号、符号扩展
**	原创
*/
//按照mips标准，寄存器编号应该符号扩展，但是最终alu只需要使用低5位，所以怎么扩展都不影响结果

module extend(
	input 		[1:0] 	ext_sel,
	input 		[4:0] 	shamt,
	input 		[15:0] 	imm16,

	output reg	[31:0] 	imm32
);
	
	wire [15:0] sign;
	
	assign sign = {imm16[15],imm16[15],imm16[15],imm16[15],imm16[15],imm16[15],
				   imm16[15],imm16[15],imm16[15],imm16[15],imm16[15],imm16[15],
				   imm16[15],imm16[15],imm16[15],imm16[15]};

	always @(*) begin
		case(ext_sel)
			2'b00: begin
				imm32 <= {sign,imm16};
			end // 2'b00:
			2'b01: begin
				imm32 <= {16'h0000,imm16};
			end // 2'b01:
			2'b10: begin
				imm32 <= {27'h0000000,shamt};
			end // 2'b10:
			default: imm32 <= 32'h0;
		endcase // ext_sel
	end // always @(*)
	
endmodule
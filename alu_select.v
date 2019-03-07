/*
**	作者：张鑫
**	功能：算术逻辑单元ALU的两个操作数的选择
**	原创
*/
module alu_select(
	input 		[1:0]		alua_sel_ex,	//EX段，ALU的第一个操作数的选择信号
	input 		[1:0]		alub_sel_ex,	//EX段，ALU的第二个操作数的选择信号
	input 		[31:0]		rdata1_ex,		//通用寄存器的第一路输出
	input 		[31:0]		rdata2_ex,		//通用寄存器的第二路输出
	input 		[31:0]		extern_ex,		//立即数扩展的结果
	
	output reg	[31:0]		alu_a,			//ALU的第一路输入
	output reg	[31:0]		alu_b			//ALU的第二路输入
);

	// 根据控制器生成的编号进行ALU操作数的选择，
	// 选择信号的编码规则见信号表，这里需要从三路当中选择一路
	always @* begin
		case(alua_sel_ex)
			2'b00: begin
				alu_a <= rdata1_ex;
			end // 2'b00:
			2'b01: begin
				alu_a <= rdata2_ex;
			end // 2'b01:
			2'b10: begin
				alu_a <= extern_ex;
			end // 2'b10:
			default: begin
				alu_a <= 32'h0;
			end // default:
		endcase
	end

	// 除了从寄存器值、立即数扩展的结果中选择，还可能选择常数16，这是lui指令需要的
	always @* begin
		case(alub_sel_ex)
			2'b00: begin
				alu_b <= rdata2_ex;
			end // 2'b00:
			2'b01: begin
				alu_b <= extern_ex;
			end // 2'b01:
			2'b10: begin
				alu_b <= 32'h0;
			end // 2'b10:
			2'b11: begin
				alu_b <= 32'd16;
			end // 2'b11:
			default: alu_b <= 32'h0;
		endcase
	end
	
endmodule

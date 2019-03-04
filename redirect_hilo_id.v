/*
**	作者：张鑫
**	功能：HILO寄存器的重定向
**	原创
*/
module redirect_hilo_id (
	input 		[63:0] 		hilo_id,
	input 		[31:0] 		alu_r1_ex,
	input 		[31:0] 		alu_r2_ex,
	input 		[31:0]		alu_r1_mem,
	input 		[31:0]		alu_r2_mem,
	input 		[31:0]		rdata1_ex,
	input 		[31:0]		rdata1_mem,
	input 		[1:0]		hilo_mode_ex,
	input 		[1:0]		hilo_mode_mem,
	
	output reg	[63:0] 		real_hilo_id
);
	
	always @(*) begin
		real_hilo_id <= hilo_id;

		case(hilo_mode_mem)
			2'b01: begin
				real_hilo_id[31:0] <= rdata1_mem;
			end
			2'b10: begin
				real_hilo_id[63:32] <= rdata1_mem;
			end
			2'b11: begin
				real_hilo_id <= { alu_r2_mem,alu_r1_mem };
			end
		endcase

		case(hilo_mode_ex)
			2'b01: begin
				real_hilo_id[31:0] <= rdata1_ex;
			end
			2'b10: begin
				real_hilo_id[63:32] <= rdata1_ex;
			end
			2'b11: begin
				real_hilo_id <= { alu_r2_ex,alu_r1_ex };
			end
		endcase
	end
	
endmodule
/*
**	作者：张鑫
**	功能：生成数据RAM的4位使能信号
**	原创
*/

module dram_mode (
	input 		[2:0]		load_store_mem,
	input 		[1:0]		data_sram_addr_byte_mem,
	
	output reg	[3:0]		mode_mem
);
	
	always @* begin
		case(load_store_mem)
			3'b101: begin	//sb
				case(data_sram_addr_byte_mem)
					2'b00: begin
						mode_mem <= 4'b0001;
					end // 2'b00:
					2'b01: begin
						mode_mem <= 4'b0010;
					end // 2'b01:
					2'b10: begin
						mode_mem <= 4'b0100;
					end // 2'b10:
					2'b11: begin
						mode_mem <= 4'b1000;
					end // 2'b11:
					default :begin
						mode_mem <= 4'b0000;
					end // default :
				endcase
			end // 3'b101:
			3'b110: begin	//sh
				case(data_sram_addr_byte_mem)
					2'b00: begin
						mode_mem <= 4'b0011;
					end
					2'b01: begin
						mode_mem <= 4'b0110;
					end // 2'b01:
					2'b10: begin
						mode_mem <= 4'b1100;
					end // 2'b10:
					2'b11: begin
						mode_mem <= 4'b1000;
					end // 2'b11:
					default :begin
						mode_mem <= 4'b0000;
					end // default :
				endcase
			end // 3'b110:
			3'b111:	begin	//sw
				mode_mem <= 4'b1111;
			end // 3'b111:
			default: begin
				mode_mem <= 4'b0000;
			end
		endcase // load_store_mem
	end // always @(*)
	
endmodule

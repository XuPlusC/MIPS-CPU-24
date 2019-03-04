/*
**	作者：张鑫
**	功能：对数据RAM的写入数据进行移位
**	原创
*/
module dm_in_select (
	input 		[31:0]		rdata2_mem,
	input 		[2:0]		load_store_mem,
	input 		[1:0]		data_sram_addr_byte_mem,
	
	output reg	[31:0]		dram_wdata_mem
);
	
	always @(*) begin
		case(load_store_mem)
			3'b101: begin	//sb
				case(data_sram_addr_byte_mem)
					2'b00: begin
						dram_wdata_mem <= rdata2_mem;
					end // 2'b00:
					2'b01: begin
						dram_wdata_mem <= { rdata2_mem[23:0],8'h00 };
					end // 2'b01:
					2'b10: begin
						dram_wdata_mem <= { rdata2_mem[15:0],16'h0000 };
					end // 2'b10:
					2'b11: begin
						dram_wdata_mem <= { rdata2_mem[7:0],24'h000000 };
					end // 2'b11:
					default: begin
						dram_wdata_mem <= rdata2_mem;
					end // default:
				endcase
			end // 3'b101:
			3'b110: begin	//sh
				case(data_sram_addr_byte_mem)
					2'b00: begin
						dram_wdata_mem <= rdata2_mem;
					end // 2'b00:
					2'b01: begin
						dram_wdata_mem <= { rdata2_mem[23:0],8'h00 };
					end // 2'b01:
					2'b10: begin
						dram_wdata_mem <= { rdata2_mem[15:0],16'h0000 };
					end // 2'b10:
					2'b11: begin
						dram_wdata_mem <= { rdata2_mem[7:0],24'h000000 };
					end // 2'b11:
					default: begin
						dram_wdata_mem <= rdata2_mem;
					end // default:
				endcase
			end // 3'b110:
			3'b111: begin	//sw
				dram_wdata_mem <= rdata2_mem;
			end // 3'b111:
			default: begin
				dram_wdata_mem <= rdata2_mem;
			end // default:
		endcase // load_store_mem
	end // always @(*)
	
endmodule

/*
**	作者：张鑫
**	功能：对数据RAM读出的数据进行字节选择
**	原创
*/
module DMout_select_extend (
	input 		[2:0]			load_store_wb,
	input 		[31:0]			DMout_wb,
	input 		[1:0]			data_sram_addr_byte_wb,
	
	output reg 	[31:0]			real_DMout_wb
);
	
	reg	[7:0]	byte_;
	reg	[15:0]	half;

	always @(*) begin
		case(data_sram_addr_byte_wb)
			2'b00: begin
				byte_ <= DMout_wb[7:0];
				half <= DMout_wb[15:0];
			end // 2'b00:
			2'b01: begin
				byte_ <= DMout_wb[15:8];
				half <= DMout_wb[15:0];
			end // 2'b01:
			2'b10: begin
				byte_ <= DMout_wb[23:16];
				half <= DMout_wb[31:16];
			end // 2'b10:
			2'b11: begin
				byte_ <= DMout_wb[31:24];
				half <= DMout_wb[31:16];
			end // 2'b11:
			default: begin
				byte_ <= DMout_wb[7:0];
				half <= DMout_wb[15:0];
			end
		endcase
	end // always @(*)

	always @(*) begin
		case(load_store_wb)
			3'b000: begin	//lb
				real_DMout_wb <= byte_[7] ? {24'hffffff,byte_} : {24'h000000,byte_};
			end // 3'b000:
			3'b001:	begin	//lbu
				real_DMout_wb <= {24'h000000,byte_};
			end // 3'b001:
			3'b010:	begin	//lh
				real_DMout_wb <= half[15] ? {16'hffff,half} : {16'h0000,half};
			end // 3'b010:
			3'b011: begin	//lhu
				real_DMout_wb <= {16'h0000,half};
			end // 3'b011:
			3'b100: begin	//lw
				real_DMout_wb <= DMout_wb;
			end // 3'b100:
			default: begin
				real_DMout_wb <= DMout_wb;
			end
		endcase
	end // always @(*)
	
endmodule

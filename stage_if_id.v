/*
**  作者：马翔
**  功能：IF-ID流水接口
**  原创
*/

module IF_ID(
	input wire 				clk,
	input wire 				rset,
	
    input wire 				stall,   
    input wire [31:0]		instruction_in,
    input wire [31:0]		PC_in,
    input 					illegal_pc_in,
    input 					in_delayslot_in,
    
    output reg [31:0]		instruction_out,
    output reg [31:0]		PC_out,
    output reg 				illegal_pc_out,
    output reg 				in_delayslot_out
);
    
    always@(posedge clk) begin
		if (!rset) begin
			instruction_out <= 32'h0;
			PC_out <= 32'h0;
			illegal_pc_out <= 1'b0;
			in_delayslot_out <= 1'b0;
		end
		else if (!stall) begin
			instruction_out <= instruction_out;
			PC_out <= PC_out;
			illegal_pc_out <= illegal_pc_out;
			in_delayslot_out <= in_delayslot_out;
		end
		else begin
			instruction_out <= instruction_in;
			PC_out <= PC_in;
			illegal_pc_out <= illegal_pc_in;
			in_delayslot_out <= in_delayslot_in;
		end 
    end
	
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:kyle
// 
// Create Date: 2019/02/22 08:38:58
// Design Name: 
// Module Name: Register_HI_LO
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 本文件实现HI,LO寄存器。为方便CPU控制，此两个寄存器的读写接口独立。
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Register_HI_LO(clk,clr,WE_HI,WE_LO,HI_in,LO_in,HI_out,LO_out);
	parameter WIDTH = 32;
	input clk,clr;
	//时钟，清零段。清零段高电平有效，优先级最高。
	input WE_HI,WE_LO;
	//HI,LO的写使能信号。高电平有效。
	input [WIDTH-1:0] HI_in,LO_in;
	//将要写入HI,LO的值
	output reg [WIDTH-1:0] HI_out,LO_out;
	//HI,LO中的值
	
	always @(posedge clk or posedge clr) begin
		if(clr == 1) begin
			HI_out = 0;
			LO_out = 0;
		end
		else begin
			if(WE_HI == 1) begin
				HI_out = HI_in;
			end
			if(WE_LO == 1) begin
				LO_out = LO_in;
			end
		end
	end
endmodule

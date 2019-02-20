`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: kyle
// 
// Create Date: 2019/02/20 22:34:34
// Design Name: 
// Module Name: MIPS_CPU_false
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 此文件用于测试顶层模块。接口与MIPS_CPU模块一致。
// 内部实现为计数器。
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MIPS_CPU_false(clr, Go, clk, Leddata, Count_all, Count_branch, Count_jmp);
    input clr, clk, Go;
    output reg [31:0] Leddata;
    output reg [31:0]Count_all, Count_branch, Count_jmp;
	
	initial begin
		Leddata = 32'h0000_0000;
		Count_all = 32'h0000_1111;
		Count_branch = 32'h1111_0000;
		Count_jmp = 32'h1111_1111;
	end
	
	always @(posedge clk)begin
		if(clr == 1) begin
			Leddata = 32'h0000_0000;
		end
		else begin
			Leddata = Leddata + 1;
		end
		Count_all = Count_all + 1;
		Count_branch = Count_branch + 1;
		Count_jmp = Count_jmp + 1;
	end
endmodule

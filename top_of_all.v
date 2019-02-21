`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/02/20 11:38:03
// Design Name: 
// Module Name: top_of_all
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top_of_all(clr,Go,clk,choose_data_show,choose_Hz,clk_N,SEG,AN);
	input clr,Go;
	input clk;
	input [2:0] choose_data_show;
	//与开关绑定，此输入决定Led显示来源
	input [1:0] choose_Hz;
	//与开关绑定，此输入决定MIPS CPU 的频率?
	output wire clk_N;
	output [7:0] SEG,AN;
	
	wire [31:0] Leddata,Count_all,Count_branch,Count_jmp;
	reg [31:0] Leddata_show;

	initial begin
		Leddata_show = 32'h0000_0000;
	end

	always @(choose_data_show) begin
		case(choose_data_show)
			0:Leddata_show = Leddata;
			1:Leddata_show = Count_all;
			2:Leddata_show = Count_jmp;
			3:Leddata_show = Count_branch;
			default:Leddata_show = Leddata;
			//default 留作扩展使用
		endcase
	end
	
	show show(clk,Leddata_show,SEG,AN);	
	MIPS_CPU_false MIPS_CPU_false(clr,Go,clk_N,Leddata,Count_all,Count_branch,Count_jmp);
	divider_dif divider_dif(clk,choose_Hz,clk_N);

endmodule

module divider_dif(clk, choose_Hz,clk_N);
//此文件接受参数，调节分频
	input clk;                      // 系统时钟
	input [1:0] choose_Hz;
	//选择频率
	//00:1000Hz,01:100Hz,10:10Hz,11:1Hz
	output reg clk_N;                   // 分频后的时钟
	reg [31:0] N;
	reg [31:0] counter;             /* 计数器变量，通过计数实现分频。
									   当计数器从0计数到(N/2-1)时，
									   输出时钟翻转，计数器清零 */ 
	initial begin
		clk_N = 0;
		counter = 0;
		N = 10_000;
	end
	
	always @(choose_Hz) begin
		case(choose_Hz)
			2'b00: N = 10_000;
			2'b01: N = 100_000;
			2'b10: N = 1_000_000;
			2'b11: N = 10_000_000;
		endcase
	end
	
	always @(posedge clk)begin    // 时钟上升沿
		// 功能实现
		if(counter % N == 0)
			begin
				clk_N = ~ clk_N;		//输出时钟翻转
				counter = 1;		//计数器清零
			end
		else
			begin
				counter = counter + 1;//计数器加一
			end
	end                           
endmodule

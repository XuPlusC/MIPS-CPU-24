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


// module top_of_all(clr, Go, clk, SEG, AN);
// 	input clr, Go,clk;
// 	output [7:0] SEG,AN;
	
// 	reg [31:0] Leddata,Count_all, Count_branch, Count_jmp;
	
// 	initial begin
// 		Leddata = 32'h0000_0000;
// 	end
	
// 	show show(clk,Leddata,SEG,AN);
// 	//test_reabmem_on_FPGA test_reabmem_on_FPGA(Leddata);
	
// 	// CPU driver
// 	wire CPU_clk;
// 	divider #( 10_000_000) (clk, CPU_clk);
// 	MIPS_CPU MIPS_CPU(clr,Go,CPU_clk,Leddata,Count_all,Count_branch,Count_jmp);

// 	LedData Led1(Syscall, R1_out, R2_out, clk, clr, Leddata);
	
// endmodule

module top_of_all(clr,Go,clk,choose_data_show,choose_Hz,SEG,AN);
	input clr,Go;
	input clk;
	input [2:0] choose_data_show;
	//与开关绑定，此输入决定Led显示来源
	input [1:0] choose_Hz;
	//与开关绑定，此输入决定MIPS CPU 的频�?
	output [7:0] SEG,AN;
	
	wire [31:0] Leddata,Count_all,Count_branch,Count_jmp;
	reg [31:0] Leddata_show;
	wire clk_N;

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
	MIPS_CPU MIPS_CPU(clr,Go,clk_N,Leddata,Count_all,Count_branch,Count_jmp);
	divider #( 10_000_000) (clk, clk_N);// divider_dif divider_dif(clk,choose_Hz,clk_N)

endmodule
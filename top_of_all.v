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


module top_of_all(/*clr,Go,*/clk,SEG,AN);
	input /*clr,Go,*/clk;
	output [7:0] SEG,AN;
	
	reg [31:0] Leddata/*,Count_all,Count_branch,Count_jmp*/;
	
	initial begin
		Leddata = 32'h87654321;
	end
	
	show show(clk,Leddata,SEG,AN);
	//test_reabmem_on_FPGA test_reabmem_on_FPGA(Leddata);
	
	/*MIPS_CPU MIPS_CPU(clr,Go,clk,Leddata,Count_all,Count_branch,Count_jmp);*/
	
endmodule

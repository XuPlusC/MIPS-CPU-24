`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: kyle
// 
// Create Date: 2019/02/19 14:27:07
// Design Name: 
// Module Name: sim_register
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


module sim_register();
	reg [31:0] Data_in;
	reg clk;
	reg clr;
	reg Enable;
	wire [31:0] Data_out;
	
	initial begin
		clk = 0;
		clr = 0;
		Data_in = 32'hffff0000;
		Enable = 1;
		
		#103;
		clr = 1;
		#5;
		clr = 0;
	end
	
	always begin
		#5;
		Data_in = Data_in + 1;
		clk = ~clk;
	end
	
	register #(.WIDTH(32)) register(Data_in,Enable,clk,clr,Data_out);
endmodule

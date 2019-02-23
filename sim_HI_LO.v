`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/02/23 17:50:40
// Design Name: 
// Module Name: sim_HI_LO
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


module sim_HI_LO();
	
	reg clk,clr,WE_HI,WE_LO;
	reg [31:0] HI_in,LO_in;
	wire [31:0] HI_out,LO_out;
	
	initial begin
		clk = 1;
		clr = 0;
		WE_HI = 0;
		WE_LO = 0;
		HI_in = 0;
		LO_in = 0;
		
		#10;
		WE_HI = 1;HI_in = 32'h8765_4321;
		#5;
		WE_HI = 0;
		#5;
		WE_LO = 1;		
		LO_in = 32'h1234_5678;
		#5;
		WE_LO = 0;
		#5;
		#20;
		clr = 1;
		#10;
		WE_HI = 1;HI_in = 32'h8765_4321;
		#5;
		WE_HI = 0;
		#5;
		WE_LO = 1;		
		LO_in = 32'h1234_5678;
		#5;
		WE_LO = 0;
		#10;
		clr = 0;
		#5;
		WE_HI = 1;HI_in = 32'h8765_4321;
		#5;
		WE_HI = 0;
		#5;
		WE_LO = 1;		
		LO_in = 32'h1234_5678;
		#5;
		WE_LO = 0;
	end
	
	always begin
		#5 clk = ~clk;
	end

	Register_HI_LO HI_LO(clk,clr,WE_HI,WE_LO,HI_in,LO_in,HI_out,LO_out);
endmodule

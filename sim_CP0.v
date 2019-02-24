`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: kyle
// 
// Create Date: 2019/02/23 18:30:09
// Design Name: 
// Module Name: sim_CP0
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


module sim_CP0();
	
	reg [4:0] R_in,W_in;
	reg [31:0] Din,EPC_in;
	reg EPC_WE,WE,clk,clr;
	reg [2:0] sel;
	
	wire [31:0] R_out,EPC_out;
	
	initial begin
		R_in=0;W_in=0;Din=0;EPC_in=0;WE=0;EPC_WE=0;sel=0;clk=0;clr=0;
		#5;
		WE = 1;
		#2555;
		WE = 0;
	end
	
	always begin
		#5;clk = ~ clk;
	end
	
	always begin
		#10;
		Din = Din + 1;
		sel = sel + 1;
	end
	
	always begin
		#80;
		W_in = W_in + 1;
		R_in = R_in + 1;
	end
	
	
	CP0 CP0(R_in,W_in,Din,EPC_in,WE,EPC_WE,sel,clk,clr,R_out,EPC_out);
endmodule

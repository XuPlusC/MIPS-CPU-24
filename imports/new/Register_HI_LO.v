`timescale 1ns / 1ps

module Register_HI_LO(clk, rst, WE, HI_in, LO_in, HI_Reg, LO_Reg);
	parameter WIDTH = 32;
	input clk, rst;
	//时钟，清零段。清零段高电平有效，优先级最高。
	input WE;
	//HI,LO的写使能信号。高电平有效。
	input [WIDTH-1:0] HI_in, LO_in;
	//将要写入HI,LO的值
	output reg [WIDTH-1:0] HI_Reg, LO_Reg;
	//HI,LO中的值
	
	initial begin
		HI_Reg <= 0;   LO_Reg <= 0;
	end
	
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			HI_Reg <= 0;   LO_Reg <= 0;
		end
		else begin
			if(WE) begin  HI_Reg <= HI_in;   LO_Reg <= LO_in; end
		end
	end
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: kyle
// 
// Create Date: 2019/02/19 10:32:15
// Design Name: 
// Module Name: Mux
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Mux_1 #(parameter WIDTH = 8) (Data_0,Data_1,select,Data_out);
	//WIDTH:参数，在实例化时，可以使用此参数扩展Data的位�?
	//实例化示例：module_name #(.parameter_name(para_value),) inst_name (port map);
	input wire [WIDTH-1:0] Data_0;
	input wire [WIDTH-1:0] Data_1;
	//以上两个input 为多路�?�择器的输入�?
	input wire select;
	//select 为�?�择�?
	output wire [WIDTH-1:0] Data_out;
	//输出�?
	
	assign Data_out = (select == 1)?Data_1:Data_0;
endmodule

module Mux_2(Data_0,Data_1,Data_2,Data_3,select,Data_out);
	parameter WIDTH = 8;
	//WIDTH:参数，在实例化时，可以使用此参数扩展Data的位�?
	//实例化示例：module_name #(.parameter_name(para_value),) inst_name
	
	input wire [WIDTH-1:0] Data_0;
	input wire [WIDTH-1:0] Data_1;
	input wire [WIDTH-1:0] Data_2;
	input wire [WIDTH-1:0] Data_3;
	//以上四个input 为多路�?�择器的输入�?
	input wire [1:0] select;
	//select 为�?�择�?
	output wire [WIDTH-1:0] Data_out;
	//输出�?
	
	wire [WIDTH-1:0] Data_out_1;
	wire [WIDTH-1:0] Data_out_2;
	
	Mux_1 #(.WIDTH(WIDTH)) Mux_1(Data_0,Data_1,select[0],Data_out_1);
	Mux_1 #(.WIDTH(WIDTH)) Mux_2(Data_2,Data_3,select[0],Data_out_2);
	Mux_1 #(.WIDTH(WIDTH)) Mux_3(Data_out_1,Data_out_2,select[1],Data_out);
		
endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: kyle
// 
// Create Date: 2019/02/22 09:34:11
// Design Name: 
// Module Name: CP0
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// CP0模块为MIPS CPU 中添入的CPO模块
// Regfile_CP0 为为实现CP0重构的Regfile，一次支持一个寄存器的读、写
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CP0(R_in,W_in,Din,EPC_in,WE,EPC_WE,sel,clk,clr,R_out,EPC_out);
	parameter WIDTH = 32;
	input [4:0] R_in;//�?要读取的寄存器编�?
	input [4:0] W_in;//�?要写入的寄存器编�?
	input [WIDTH-1:0] Din;//�?要写入的�?
	input [WIDTH-1:0] EPC_in;//为EPC单独暴露的写数据端口
	input EPC_WE;//为EPC单独暴露的写使能端口
	input WE,clk,clr;
	//写使能，高电平有�?
	//异步清零，优先级�?�?
	input [2:0] sel;
	//为了支持MTC0,MFC0的sel域增添的选择信号
	output reg [WIDTH-1:0] R_out;
	output reg [WIDTH-1:0] EPC_out;
	
	wire WE_0,WE_1,WE_2,WE_3,WE_4,WE_5,WE_6,WE_7;
	wire [WIDTH-1:0] R_out_0;
	wire [WIDTH-1:0] R_out_1;
	wire [WIDTH-1:0] R_out_2;
	wire [WIDTH-1:0] R_out_3;
	wire [WIDTH-1:0] R_out_4;
	wire [WIDTH-1:0] R_out_5;
	wire [WIDTH-1:0] R_out_6;
	wire [WIDTH-1:0] R_out_7;
	
	initial begin
		EPC_out = 0;
	end
	
	always @(posedge clk or posedge clr)begin
		if(clr) begin
			EPC_out = 0;
		end
		else if(WE) begin
			EPC_out = EPC_in;
		end
	end
	
	always @(*) begin
		case(sel)
			0:R_out = R_out_0;
			1:R_out = R_out_1;
			2:R_out = R_out_2;
			3:R_out = R_out_3;
			4:R_out = R_out_4;
			5:R_out = R_out_5;
			6:R_out = R_out_6;
			7:R_out = R_out_7;
		endcase		
	end
	
	
	decoder_for_CP0 decoder(WE,sel,{WE_7,WE_6,WE_5,WE_4,WE_3,WE_2,WE_1,WE_0});
	
	Regfile_CP0 Reg0(R_in,W_in,Din,WE_0,clk,clr,R_out_0);
	Regfile_CP0 Reg1(R_in,W_in,Din,WE_1,clk,clr,R_out_1);
	Regfile_CP0 Reg2(R_in,W_in,Din,WE_2,clk,clr,R_out_2);
	Regfile_CP0 Reg3(R_in,W_in,Din,WE_3,clk,clr,R_out_3);
	Regfile_CP0 Reg4(R_in,W_in,Din,WE_4,clk,clr,R_out_4);
	Regfile_CP0 Reg5(R_in,W_in,Din,WE_5,clk,clr,R_out_5);
	Regfile_CP0 Reg6(R_in,W_in,Din,WE_6,clk,clr,R_out_6);
	Regfile_CP0 Reg7(R_in,W_in,Din,WE_7,clk,clr,R_out_7);
		
endmodule

module decoder_for_CP0(signal_in,select,signal_out);
	input signal_in;
	input [2:0] select;
	output reg [7:0] signal_out;
	//本模块是为了CP0模块中的写使能信号专用的3_8译码�?
	
	reg zero;
	
	initial begin
		zero = 0;
		signal_out = 0;
	end
	
	always@(signal_in or select) begin
		if(select == 0) begin
			signal_out[0] <= signal_in;
			signal_out[1] <= zero;
			signal_out[2] <= zero;
			signal_out[3] <= zero;
			signal_out[4] <= zero;
			signal_out[5] <= zero;
			signal_out[6] <= zero;
			signal_out[7] <= zero;
		end
		else if(select == 1) begin
			signal_out[0] <= zero;
			signal_out[1] <= signal_in;
			signal_out[2] <= zero;
			signal_out[3] <= zero;
			signal_out[4] <= zero;
			signal_out[5] <= zero;
			signal_out[6] <= zero;
			signal_out[7] <= zero;
		end
		else if(select == 2) begin
			signal_out[0] <= zero;
			signal_out[1] <= zero;
			signal_out[2] <= signal_in;
			signal_out[3] <= zero;
			signal_out[4] <= zero;
			signal_out[5] <= zero;
			signal_out[6] <= zero;
			signal_out[7] <= zero;
		end
		else if(select == 3) begin
			signal_out[0] <= zero;
			signal_out[1] <= zero;
			signal_out[2] <= zero;
			signal_out[3] <= signal_in;
			signal_out[4] <= zero;
			signal_out[5] <= zero;
			signal_out[6] <= zero;
			signal_out[7] <= zero;
		end
		else if(select == 4) begin
			signal_out[0] <= zero;
			signal_out[1] <= zero;
			signal_out[2] <= zero;
			signal_out[3] <= zero;
			signal_out[4] <= signal_in;
			signal_out[5] <= zero;
			signal_out[6] <= zero;
			signal_out[7] <= zero;
		end
		else if(select == 5) begin
			signal_out[0] <= zero;
			signal_out[1] <= zero;
			signal_out[2] <= zero;
			signal_out[3] <= zero;
			signal_out[4] <= zero;
			signal_out[5] <= signal_in;
			signal_out[6] <= zero;
			signal_out[7] <= zero;
		end
		else if(select == 6) begin
			signal_out[0] <= zero;
			signal_out[1] <= zero;
			signal_out[2] <= zero;
			signal_out[3] <= zero;
			signal_out[4] <= zero;
			signal_out[5] <= zero;
			signal_out[6] <= signal_in;
			signal_out[7] <= zero;
		end
		else if(select == 7) begin
			signal_out[0] <= zero;
			signal_out[1] <= zero;
			signal_out[2] <= zero;
			signal_out[3] <= zero;
			signal_out[4] <= zero;
			signal_out[5] <= zero;
			signal_out[6] <= zero;
			signal_out[7] <= signal_in;
		end
		else begin
			signal_out[0] <= zero;
			signal_out[1] <= zero;
			signal_out[2] <= zero;
			signal_out[3] <= zero;
			signal_out[4] <= zero;
			signal_out[5] <= zero;
			signal_out[6] <= zero;
			signal_out[7] <= zero;
		end
	end
endmodule

module Regfile_CP0(R_in,W_in,Din,WE,clk,clr,R_out);
	parameter WIDTH = 32;
	input [4:0] R_in;//�?要读取的寄存器编�?
	input [4:0] W_in;//�?要写入的寄存器编�?
	input [WIDTH-1:0] Din;//�?要写入的�?
	input WE,clk,clr;
	//写使能，高电平有�?
	//异步清零，优先级�?�?
	output [WIDTH-1:0] R_out;
	
	reg [WIDTH-1:0] Reg [31:0];
	//寄存器文件组
	
	integer i;
	initial begin
		for(i=0;i<32;i = i+1) Reg[i] = 0;
	end
	
	always @(posedge clk or posedge clr)begin
		if(clr) begin
			for(i = 0;i < 32;i = i+1)
				Reg[i] = 0;
		end
		else if(WE == 1) begin
			Reg[W_in] = Din;
		end
		else begin
			Reg[W_in] = Reg[W_in];
		end
	end
	
	assign R_out = Reg[R_in];
endmodule
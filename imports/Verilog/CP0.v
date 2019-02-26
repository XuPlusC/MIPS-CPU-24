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
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CP0(R_in,W_in,Din,WE,sel,clk,clr,NMI_one,NMI_zero,IE_one,IE_zero, IntRequest, EPC_in,  
				NMI_out,IE_out,R_out, EPC_out);
	parameter WIDTH = 32;
	input [4:0] R_in;
	input [4:0] W_in;
	input [WIDTH-1:0] Din, EPC_in;
	input WE,clk,clr;
	input NMI_one,NMI_zero,IE_one,IE_zero, IntRequest;
	input [2:0] sel;
	output wire NMI_out,IE_out;
	output reg [WIDTH-1:0] R_out;
	output [WIDTH-1:0]EPC_out;

	reg [WIDTH-1:0] cause,status,EPC;

	initial begin
		cause = 0;
		status = 32'b1111_1111_1111_1011_1111_1111_1111_1111;
		EPC = 0;
	end

	assign NMI_out = status[19];
	assign IE_out = status[0];
	always @(posedge clk) begin
	//write cause
		if(clr == 1) begin
			cause = 0;
		end
		else if(WE && W_in == 13)begin
			cause = Din;
		end
		else begin
			cause = cause;
		end
	end

	always @(posedge clk or posedge IntRequest) begin
	//write EPC
		if(clr == 1) begin
			EPC = 0;
		end
		else if(IntRequest == 1) begin
			EPC = EPC_in;
		end
		else if(WE && W_in == 14)begin
			EPC = Din;
		end
		else begin
			EPC = EPC;
		end
	end

	always @(posedge clk) begin
		if(clr == 1) begin
			status = 0;
		end
		else if(WE && W_in == 12)begin
			status = Din;
		end
		else begin 
			if(NMI_one == 1) begin
				status = status | 32'b0000_0000_0000_0100_0000_0000_0000_0000;
			end
			else if(NMI_zero == 1) begin
				status = status & 32'b1111_1111_1111_1011_1111_1111_1111_1111;
			end
			if(IE_one == 1) begin
				status = status | 32'b0000_0000_0000_0000_0000_0000_0000_0001;
			end
			else if(IE_zero == 1)begin
				status = status & 32'b1111_1111_1111_1111_1111_1111_1111_1110;
			end
			// else begin
			// 	status = status & 32'b1111_1111_1111_1111_1111_1111_1111_1110;
			// end
		end
//		else begin
//			EPC = EPC;
//		end
	end

	always @(*) begin
	//read from CP0
		case(R_in)
			12:begin
				R_out = status;
			end
			13:begin
				R_out = cause;
			end
			14:begin
				R_out = EPC;
			end
			default:begin
				R_out = 0;
			end
		endcase
	end

	assign EPC_out = EPC;
endmodule
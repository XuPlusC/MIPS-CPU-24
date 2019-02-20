`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/02/20 20:30:07
// Design Name: 
// Module Name: LedData
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

module LedData(Syscall, R1_out, R2_out, clk, clr, leddata);
    input Syscall, clk, clr;
    input [31:0] R1_out, R2_out;
    output [31:0]leddata;
    wire Enable;
    assign Enable = Syscall & (R1_out == 34);
    register register1 (R2_out, Enable, clk, clr, leddata);
endmodule

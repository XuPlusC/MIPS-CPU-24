`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/02/19 15:32:48
// Design Name: 
// Module Name: ROM_tb
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

module PCenable(R1_out, Syscall, Go, enable);
    input [31:0]R1_out;
    input Syscall, Go;
    output enable;

    assign enable = (R1_out == 32'h00000022) | ~Syscall | Go;
endmodule

module Path_ROM_to_Reg(Order, Jal, Regdst, R1, R2, W);
    input [31:0]Order;
    input Jal, Regdst;
    output [4:0]R1, R2, W;

    assign R1 = (Syscall == 1)?5'b00010 : Order[25:21];
    assign R2 = (Syscall == 1)?5'b00100 : Order[20:16];
    assign W = (Regdst == 0)?((Jal == 0)?(Order[20:16]):(5'b11111)):((Jal == 0)?(Order[15:11]):(5'b00000));
    // 5'b00000 stands for error
endmodule

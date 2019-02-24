`timescale 1ns / 1ps

module WB(clk, rst, Order, RegFile_Din, Write_Reg_num, Reg_Write_enable, HI_LO_Write_enable, HI_in, HI_Write_to_GPR, LO_Write_to_GPR,
        RegFile_Din_out);
    input [31:0]RegFile_Din, Order, HI_in;
    input [4:0]Write_Reg_num;
    input clk, rst, Reg_Write_enable, HI_LO_Write_enable, HI_Write_to_GPR, LO_Write_to_GPR;
    output [31:0]RegFile_Din_out;
    
    wire [31:0]HI_out, LO_out;
    Register_HI_LO hi_lo(clk, rst, HI_LO_Write_enable, HI_in, RegFile_Din, HI_out, LO_out);
    assign RegFile_Din_out = HI_Write_to_GPR ? HI_out : (LO_Write_to_GPR ? LO_out : RegFile_Din);
endmodule

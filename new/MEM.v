`timescale 1ns / 1ps

module MEM(clk, rst, Din, Order, ALU_result, PC_plus_4, Mode, Write_enable, Sel, Read_enable, Byte, Signext2, Jal,
        RegFile_Din);
    input clk, rst;
    input [31:0]Din, ALU_result, PC_plus_4, Order;
    input [1:0]Mode;
    input Write_enable, Sel, Read_enable, Byte, Signext2, Jal;
    //WB�׶���������
    output [31:0]RegFile_Din;
    
    wire [31:0]mem;
    //���ݴ洢��,SelΪƬѡ�ź�
    RAM DATA_RAM(ALU_result[11:0], Din, Mode, Write_enable, Sel, clk, rst, Read_enable, mem);

    //ѡ����Ҫд�ص�����Ϊmem����ALU_result
    Data_to_Din Din1(Byte, Signext2, mem, ALU_result, PC_plus_4, Jal, Read_enable, RegFile_Din);
endmodule
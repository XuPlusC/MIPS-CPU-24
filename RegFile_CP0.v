﻿`timescale 1ns / 1ps

module RegFile(R1_in, R2_in, W1_in, W2_in, Din1, Din2, WE, clk, R1_out, R2_out);
    parameter WIDTH=32;     //默认位宽为32
    input [4:0] R1_in;      //需要读取的寄存器A编号
    input [4:0] R2_in;      //需要读取的寄存器B编号
    input [4:0] W1_in;       //需要写入的寄存器编号
    input [4:0] W2_in;      //乘除指令时需同时写入两个寄存器
    input [WIDTH-1:0] Din1;  //需要写入的值
    input [WIDTH-1:0] Din2;   //乘除指令时需写入的第二个寄存器的值
    input WE,clk;   //使能端和时钟信号
    output [WIDTH-1:0] R1_out;  //寄存器A的值
    output [WIDTH-1:0] R2_out;  //寄存器B的值

    reg [WIDTH-1:0]Reg[31:0];       //寄存器文件组（32个寄存器）
    integer i;
    initial begin       //寄存器值初始为0
        for(i=0; i<32; i=i+1) Reg[i]=0;
    end

    always @(posedge clk) begin
        if(WE)  begin   Reg[W1_in] = Din1;   Reg[W2_in] = Din2; end
    end

    assign R1_out = Reg[R1_in];
    assign R2_out = Reg[R2_in];
endmodule

`timescale 1ns / 1ps

module PCenable(R1_out, Syscall, Go, clk, enable);
    input [31:0]R1_out;
    input Syscall, Go, clk;
    output enable;
    assign enable = (R1_out == 32'h00000022) | ~Syscall | Go ;

endmodule

module Path_ROM_to_Reg(Order, Jal, Regdst, Syscall, R1, R2, W);
    input [31:0]Order;
    input Jal, Regdst;
    input Syscall;
    output [4:0]R1, R2, W;

    assign R1 = (Syscall == 1)?5'b00010 : Order[25:21];
    assign R2 = (Syscall == 1)?5'b00100 : Order[20:16];
    assign W = (Regdst == 0)?((Jal == 0)?(Order[20:16]):(5'b11111)):((Jal == 0)?(Order[15:11]):(5'b00000));
    // 5'b00000 stands for error
endmodule

module shamt_input(Order, R1_out, shift, Lui, shamt);
    input [31:0] Order;
    input [31:0] R1_out;
    input shift, Lui;
    output [4:0]shamt;
    assign shamt = (shift == 1) ? R1_out :
                    (Lui == 1) ? 16 : Order [10:6];
endmodule

module Extern(Order, Signedext, imm, ext18);
    input [31:0]Order;
    input Signedext;
    output [31:0]imm, ext18;
    wire [15:0]temp;
    assign temp = Order[15]?16'hFFFF:16'h0;
    assign imm = (Signedext == 1)?{temp, Order[15:0]}:{16'h0, Order[15:0]};
    assign ext18 = {temp, Order[15:0]}<<2;
endmodule

module Data_to_Din(Byte, Signext2, mem, Result1, PC_plus_4, Jal, Memtoreg, Din);
    input Byte,Signext2;
    input [31:0] mem, Result1, PC_plus_4;
    input Jal, Memtoreg;
    output [31:0] Din;
    wire [15:0]temp1;
    wire [23:0]temp2;
    assign temp1 = mem[15]?16'hFFFF:16'h0;
    assign temp2 = mem[7]?24'hFFFFFF:24'h0;
    assign Din = (Memtoreg == 1)?mem:
                (Jal == 1)?PC_plus_4:
                (Signext2 == 1)?((Byte == 1)? {temp2, mem[7:0]}:{temp1, mem[15:0]}):
                Result1;

endmodule

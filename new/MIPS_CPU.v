`timescale 1ns / 1ps

module MIPS_CPU(clr, Go, clk, Leddata, Count_all, Count_branch, Count_jmp);
    input clr, clk, Go;
    output [31:0] Leddata;
    output [31:0]Count_all, Count_branch, Count_jmp;
    //control接出的控制信号
    wire Memtoreg, Memwrite, Alu_src, Regwrite, Syscall, Signedext, Regdst, 
        Beq, Bne, Jr, Jmp, Jal, Shift, Lui, Blez, Bgtz, Bz;
    wire [1:0]Mode;
    wire [3:0] ALU_OP;
    //控制器相关
    wire [31:0] Order;
    wire [5:0] OP, Func;
    //Regfile相关
    wire [4:0]R1_in, R2_in, W_in;
    wire [31:0]R1_out, R2_out, Din;
    wire [31:0] mem;//**********需结合RAM
    //ALU 相关
    wire [31:0]X, Y;
    wire [4:0] shamt;
    wire [31:0] Result1, Result2;
    wire UOF, OF;//not used
    wire Equal;
    wire [31:0]imm;
    //branch 相关
    wire Branch_out;
    //PC相关
    wire [31:0]PC, ext18, PC_next_clk, PC_plus_4;
    wire [26:0] target;
    wire enable;
    
    //RAM
    

    //控制器相关
    assign OP = Order[31:26];
    assign Func = Order[5:0];
    control control1(OP, Func, ALU_OP, Memtoreg, Memwrite, Alu_src, Regwrite, Syscall, Signedext, Regdst, Beq, Bne, Jr, Jmp, 
        Jal, Shift, Lui, Blez, Bgtz, Bz, Mode);
    //Regfile相关
    Path_ROM_to_Reg rom_to_reg1(Order, Jal, Regdst, Syscall, R1_in, R2_in, W_in);
    RegFile regfile1 (R1_in, R2_in, W_in, Din, Regwrite, clk, R1_out, R2_out);
    Data_to_Din din1 (mem, Result1, PC_plus_4, Jal, Memtoreg, Din);
    //ALU 相关
    assign X = R1_out;
    Mux_1 mux1 (R2_out, imm, Alu_src, Y);
    shamt_input shamt1(Order, R1_out, Shift, Lui, shamt);
    ALU alu1 (X, Y, ALU_OP, shamt, Result1, Result2, OF, UOF, Equal);
    //branch 相关
    Branch branch1(Bne, Beq, Blez, Bgtz, Bz, Equal, Order[16], R1_out , Branch_out);
    //PC相关
    assign target = Order[25:0];
    PC_data PC_data1(PC, ext18, target, Branch_out, Jmp, Jr, R1_out, PC_next_clk, PC_plus_4);
    PCenable PCenable1 (R1_out, Syscall, Go, clk, enable);
    register PC1 (PC_next_clk, enable,clk,clr,PC);
    //extern
    Extern extern1 (Order, Signedext, imm, ext18);
    //计数
    Counter_circle counter_circle1(clk, clr, Branch_out, Jmp, enable, Count_all, Count_branch, Count_jmp);
    //ROM
    ROM ROM1(PC[4:0], 0, 10, 0, 1, clk, clr, 1, Order);
    //RAM
    RAM RAM1(Result1[4:0], R2_out, Mode, Memwrite, 1, clk, clr, 1, mem);

endmodule

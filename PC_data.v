`timescale 1ns / 1ps

module PC_data(PC, ext18, target, branch, Jmp, Jr, RS_data, PC_next_clk);
    input [31:0] PC;//当前PC
    input [31:0] ext18;//立即数符号扩展
    input [19:0] target;//无条件跳转的目标地址
    input branch, Jmp, Jr;//有条件跳转，jmp，jr指令
    input [31:0] RS_data;//$rs,用于jr指令
    output reg [31:0] PC_next_clk;
    
    reg [31:0]PC_plus_4;
    reg [31:0] jmp_addr;
    reg [31:0]branch_addr;
    initial begin
        PC_next_clk <= 0;
        PC_next_clk <= 0;
        jmp_addr <= 0;
        branch_addr <= 0;
    end


    always @(PC)begin
        PC_plus_4 = PC + 4;
        jmp_addr = {PC[31:22], target, 2'b00};
        branch_addr = PC_plus_4 + ext18;
        if(branch == 1) PC_next_clk = branch_addr;//有条件分支跳转
        else if(jr == 1) PC_next_clk = RS_data;
        else if (jmp == 1) PC_next_clk = jmp_addr;
        else PC_next_clk = PC_plus_4;  
    end
endmodule

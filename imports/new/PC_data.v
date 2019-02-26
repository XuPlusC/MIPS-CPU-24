`timescale 1ns / 1ps

module PC_data(PC_plus_4, ext18, target, branch, Jmp, Jr, RS_data, PC_EX, PC_next_clk);
    input [31:0] PC_plus_4;//IF阶段下一条指令
    input [31:0] ext18;//立即数符号扩展
    input [25:0] target;//无条件跳转的目标地址
    input branch, Jmp, Jr;//有条件跳转，jmp，jr指令
    input [31:0] RS_data;//$rs,用于jr指令
    input [31:0] PC_EX;//EX阶段PC +4 值
    output [31:0] PC_next_clk;
                        
    wire [31:0] jmp_addr;
    wire [31:0]branch_addr;

    assign jmp_addr = {PC_EX[31:28], target, 2'b00};
    assign branch_addr = PC_EX + ext18;
    assign PC_next_clk = (branch == 1)?branch_addr:
                        (Jr == 1)?RS_data:
                        (Jmp == 1)?jmp_addr:PC_plus_4; 
endmodule

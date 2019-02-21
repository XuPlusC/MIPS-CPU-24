`timescale 1ns / 1ps

module PC_data(PC_plus_4, ext18, target, branch, Jmp, Jr, RS_data, PC_EX, PC_next_clk);
    input [31:0] PC_plus_4;//IF�׶���һ��ָ��
    input [31:0] ext18;//������������չ
    input [25:0] target;//��������ת��Ŀ���ַ
    input branch, Jmp, Jr;//��������ת��jmp��jrָ��
    input [31:0] RS_data;//$rs,����jrָ��
    input [31:0] PC_EX;//EX�׶�PC +4 ֵ
    output [31:0] PC_next_clk;
                        
    wire [31:0] jmp_addr;
    wire [31:0]branch_addr;

    assign jmp_addr = {PC_EX[31:28], target, 2'b00};
    assign branch_addr = PC_EX + ext18;
    assign PC_next_clk = (branch == 1)?branch_addr:
                        (Jr == 1)?RS_data:
                        (Jmp == 1)?jmp_addr:PC_plus_4; 
endmodule

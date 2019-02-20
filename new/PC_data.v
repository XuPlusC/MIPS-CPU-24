`timescale 1ns / 1ps

module PC_data(PC, ext18, target, branch, Jmp, Jr, RS_data, PC_next_clk, PC_plus_4);
    input [31:0] PC;//��ǰPC
    input [31:0] ext18;//������������չ
    input [25:0] target;//��������ת��Ŀ���ַ
    input branch, Jmp, Jr;//��������ת��jmp��jrָ��
    input [31:0] RS_data;//$rs,����jrָ��
    output reg [31:0] PC_next_clk;
    
    output [31:0]PC_plus_4;
    reg [31:0] jmp_addr;
    reg [31:0]branch_addr;
    initial begin
        PC_next_clk <= 0;
        PC_next_clk <= 0;
        jmp_addr <= 0;
        branch_addr <= 0;
    end

    assign PC_plus_4 = PC + 4;
    always @(PC)begin
        jmp_addr = {PC[31:28], target, 2'b00};
        branch_addr = PC_plus_4 + ext18;
        if(branch == 1) PC_next_clk = branch_addr;//��������֧��ת
        else if(Jr == 1) PC_next_clk = RS_data;
        else if (Jmp == 1) PC_next_clk = jmp_addr;
        else PC_next_clk = PC_plus_4;  
    end
endmodule

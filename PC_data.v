`timescale 1ns / 1ps

module PC_data(PC, imm, target, branch, jmp, jr, RS_data, PC_next_clk);
    input [31:0] PC;//��ǰPC
    input [31:0] imm;//������������չ
    input [19:0] target;//��������ת��Ŀ���ַ
    input branch, jmp, jr;//��������ת��jmp��jrָ��
    input [31:0] RS_data;//$rs,����jrָ��
    output reg [31:0] PC_next_clk;
    
    reg [31:0]PC_plus_4;
    reg [17:0]ext18;
    reg [31:0] jmp_addr;
    reg [31:0]branch_addr;
    initial begin
        PC_next_clk <= 0;
        PC_next_clk <= 0;
        ext18 <= 0;
        jmp_addr <= 0;
        branch_addr <= 0;
    end


    always @(PC)begin
        PC_plus_4 = PC + 4;
        ext18 = imm << 2;
        jmp_addr = {PC[31:22], target, 2'b00};
        branch_addr = PC_plus_4 + ext18;
        if(branch == 1) PC_next_clk = branch_addr;//��������֧��ת
        else if(jr == 1) PC_next_clk = RS_data;
        else if (jmp == 1) PC_next_clk = jmp_addr;
        else PC_next_clk = PC_plus_4;  
    end
endmodule

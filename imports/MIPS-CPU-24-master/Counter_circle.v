`timescale 1ns / 1ps

module Counter_circle(clk, clr, branch, jmp, Enable, Count_all, Count_branch, Count_jmp);
    input clk, clr, branch, jmp, Enable;
    output wire[31:0]Count_all, Count_branch, Count_jmp;
    
    Counter count_all(Enable, clk, clr, Count_all);
    Counter count_branch(Enable&branch, clk, clr, Count_branch);
    Counter count_jmp(Enable&jmp, clk, clr, Count_jmp);
endmodule

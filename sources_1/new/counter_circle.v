`timescale 1ns / 1ps

module Counter_circle(clk, clr, branch, jmp, Syscall, R1_out, Count_all, Count_branch, Count_jmp);
    input clk, clr, branch, jmp, Syscall;
    input [31:0]R1_out;
    output wire[31:0]Count_all, Count_branch, Count_jmp;
    wire Enable;
    assign Enable = (~Syscall)|(Syscall & (R1_out == 34));

    Counter count_all(Enable, clk, clr, Count_all);
    Counter count_branch(branch, clk, clr, Count_branch);
    Counter count_jmp(jmp, clk, clr, Count_jmp);
endmodule

`timescale 1ns / 1ps

module Counter_circle(clk, clr, branch, jmp, Syscall, pipe, load_use, redirect, R1_out, 
                Count_all, Count_branch, Count_jmp, Count_pipe, Count_load_use, Count_redirect);
    input clk, clr, branch, jmp, Syscall, pipe, load_use, redirect;
    input [31:0]R1_out;
    output wire[31:0]Count_all, Count_branch, Count_jmp, Count_pipe, Count_load_use, Count_redirect;
    wire Enable;
    assign Enable = (~Syscall)|(Syscall & (R1_out == 34));

    Counter count_all(Enable, clk, clr, Count_all);
    Counter count_branch(branch, clk, clr, Count_branch);
    Counter count_jmp(jmp, clk, clr, Count_jmp);
    Counter count_pipe(pipe, clk, clr, Count_pipe);
    Counter count_load_use(load_use, clk, clr, Count_load_use);
    Counter count_redirect(redirect & Enable, clk, clr, Count_redirect);
endmodule

`timescale 1ns / 1ps

module Counter_circle_test();
    reg clk, clr, branch, jmp, Enable;
    wire[31:0]Count_all, Count_branch, Count_jmp;
    
    Counter_circle test(clk, clr, branch, jmp, Enable, Count_all, Count_branch, Count_jmp);
    
    always #10 clk=~clk;
    initial begin
        clk=0;  clr=0;  branch=0;   jmp=0;  Enable=1;
        #10;    branch=1;
        #100;   branch=0;   jmp=1;
        #100;
        $stop;
    end
endmodule

`timescale 1ns / 1ps

module Counter_test();
        reg Enable,clk,clr;
        wire[31:0] res;
        
        Counter test(Enable, clk, clr, res);
        always #5  clk=~clk;
        initial begin 
            Enable=0;    clk=0;     clr=0; 
            #10;    Enable=1;
            #100;   clr=1;
            #20;    clr=0;
            #50;
            $stop;
        end
        
        
endmodule

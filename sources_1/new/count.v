`timescale 1ns / 1ps

module Counter(Enable, clk, clr, res);
    parameter WIDTH = 32;
    input Enable,clk,clr;
    output reg [WIDTH-1:0] res;
    
    initial begin
        res = 0;
    end
    
    always @(posedge clk) begin
        if(clr) res=0;
        else if(Enable) res=res+1;
    end
endmodule

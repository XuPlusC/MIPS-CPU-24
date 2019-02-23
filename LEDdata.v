`timescale 1ns / 1ps

module LedData(Syscall, R1_out, R2_out, clk, clr, leddata);
    input Syscall, clk, clr;
    input [31:0] R1_out, R2_out;
    output [31:0]leddata;
    wire Enable;
    assign Enable = Syscall & (R1_out == 34);
    register register1 (R2_out, Enable, clk, clr, leddata);
endmodule

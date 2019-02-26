`timescale 1ns / 1ps

module IF(PC_in, PC_enable, clk, rst, PC_plus_4, Order);
    input [31:0]PC_in;
    input PC_enable, clk, rst;
    output [31:0]PC_plus_4, Order;
    
    wire [31:0]PC_out;
    register PC_register(PC_in, PC_enable, clk, rst, PC_out);
    ROM Order_ROM(PC_out[11:0], 32'h0, 2'b10, 1'b0, 1'b1, clk, rst, 1'b1, Order);
    assign PC_plus_4 = PC_out + 4;
endmodule

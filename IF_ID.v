`timescale 1ns / 1ps

module IF_ID(clk, rst, enable, Order_in, PC_plus_4_in, PC_plus_4_out, Order_out);
    input clk, rst, enable;
    input [31:0]Order_in, PC_plus_4_in;
    output reg[31:0]Order_out, PC_plus_4_out;
    initial begin
        Order_out<=0;   PC_plus_4_out<=0;
    end

    always @(posedge clk) begin
        if(rst) begin   
            Order_out<=0;   PC_plus_4_out<=0;
        end
        else if(enable) begin
            Order_out<=Order_in;    PC_plus_4_out<=PC_plus_4_in;
        end
    end
endmodule

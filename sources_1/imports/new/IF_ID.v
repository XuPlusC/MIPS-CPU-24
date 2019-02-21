`timescale 1ns / 1ps

module IF_ID(input [31:0]Order_in, PC_plus_4_in,
            input clk,clr,Enable_in,
            
            output reg [31:0]Order_out, PC_plus_4_out,
            output reg Enable_out
        );
        
        initial begin   Order_out<=0;   PC_plus_4_out<=0;   Enable_out<=0;  end
        always @(posedge clk) begin
            if(clr) begin   Order_out<=0;   PC_plus_4_out<=0;   Enable_out<=0;  end
            else if(Enable_in) begin
                Order_out<=Order_in;    PC_plus_4_out<=PC_plus_4_in;    Enable_out<=Enable_in;
            end
        end
endmodule

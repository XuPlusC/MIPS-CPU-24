`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:kyle
// 
// Create Date: 2019/02/19 10:54:47
// Design Name: 
// Module Name: sim_mux
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 此文件为Mux.v的仿真文件。其中提供了Mux的实例化示例。
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sim_mux();
    reg [15:0] Data_0;
    reg [15:0] Data_1;
    reg [15:0] Data_2;
    reg [15:0] Data_3;
    reg [1:0] select;
    wire [15:0] Data_out;
    
    initial begin
        Data_0 = 0;
        Data_1 = 8'b 00001111;
		Data_2 = 8'b 11110000;
		Data_3 = 8'b 11111111;
        select = 0;
    end
    
    always begin
        #5;
		Data_0 = Data_0 + 1;
        Data_1 = Data_1 - 1;
		Data_2 = Data_2 + 1;
        Data_3 = Data_3 - 1;
        select = select + 1;
    end
    
    Mux_2 #(.WIDTH(16)) Mux_2_test(Data_0,Data_1,Data_2,Data_3,select,Data_out);
endmodule

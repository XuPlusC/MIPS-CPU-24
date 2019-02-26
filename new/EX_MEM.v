`timescale 1ns / 1ps

module EX_MEM(clk, rst, enable, Order_in, ALU_result_in, PC_plus_4_in, B_in, Mode_in, Memwrite_in, Memread_in, Byte_in, Signext2_in, Jal_in, Write_Reg_num_in, 
            Reg_Write_enable_in, HI_LO_Write_enable_in, ALU_result2_in, HI_Write_to_GPR_in, LO_Write_to_GPR_in,
            
        Order_out, ALU_result_out, PC_plus_4_out, B_out, Mode_out, Memwrite_out, Memread_out, Byte_out, Signext2_out, Jal_out, Write_Reg_num_out, 
        Reg_Write_enable_out, HI_LO_Write_enable_out, ALU_result2_out, HI_Write_to_GPR_out, LO_Write_to_GPR_out);
    input clk, rst, enable, Memwrite_in, Memread_in, Byte_in, Signext2_in, Jal_in, Reg_Write_enable_in, HI_LO_Write_enable_in, HI_Write_to_GPR_in, LO_Write_to_GPR_in;
    input [4:0]Write_Reg_num_in;
    input [31:0]ALU_result_in, PC_plus_4_in, B_in, Order_in, ALU_result2_in;
    input [1:0]Mode_in;
    output reg Memwrite_out, Memread_out, Byte_out, Signext2_out, Jal_out, Reg_Write_enable_out, HI_LO_Write_enable_out, HI_Write_to_GPR_out, LO_Write_to_GPR_out;
    output reg[4:0]Write_Reg_num_out;
    output reg[31:0]ALU_result_out, PC_plus_4_out, B_out, Order_out, ALU_result2_out;
    output reg[1:0]Mode_out;

    initial begin
        Memwrite_out<=0;    Memread_out<=0;  Byte_out<=0;    Signext2_out<=0;    Jal_out<=0;    B_out<=0;   Order_out<=0;
        Reg_Write_enable_out<=0;    Write_Reg_num_out<=0;   ALU_result_out<=0;  PC_plus_4_out<=0;   Mode_out<=0;
        HI_LO_Write_enable_out<=0;  ALU_result2_out<=0;     HI_Write_to_GPR_out<=0;     LO_Write_to_GPR_out<=0;
    end

    always @(posedge clk) begin
        if(rst) begin   
            Memwrite_out<=0;    Memread_out<=0;  Byte_out<=0;    Signext2_out<=0;    Jal_out<=0;     B_out<=0;  Order_out<=0;
            Reg_Write_enable_out<=0;    Write_Reg_num_out<=0;   ALU_result_out<=0;  PC_plus_4_out<=0;   Mode_out<=0;
            HI_LO_Write_enable_out<=0;  ALU_result2_out<=0;     HI_Write_to_GPR_out<=0;     LO_Write_to_GPR_out<=0;
        end
        else if(enable) begin
            Memwrite_out<=Memwrite_in;    Byte_out<=Byte_in;    Signext2_out<=Signext2_in;    
            Jal_out<=Jal_in;     Reg_Write_enable_out<=Reg_Write_enable_in;     B_out<=B_in;
            Write_Reg_num_out<=Write_Reg_num_in;   ALU_result_out<=ALU_result_in;   Order_out<=Order_in;
            PC_plus_4_out<=PC_plus_4_in;   Mode_out<=Mode_in;   Memread_out<=Memread_in;
            HI_LO_Write_enable_out<=HI_LO_Write_enable_in;  ALU_result2_out<=ALU_result2_in;
            HI_Write_to_GPR_out<=HI_Write_to_GPR_in;     LO_Write_to_GPR_out<=LO_Write_to_GPR_in;
        end
    end
endmodule

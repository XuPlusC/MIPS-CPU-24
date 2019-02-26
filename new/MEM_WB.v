`timescale 1ns / 1ps

module MEM_WB(clk, rst, enable, Order_in, RegFile_Din_in, Write_Reg_num_in, Reg_Write_enable_in, HI_LO_Write_enable_in,
        ALU_result2_in, HI_Write_to_GPR_in, LO_Write_to_GPR_in, Circular_ERET_From_WB, MEM_WB_NOINT_NextPC, MEM_WB_INT_PC_Choose, 
        PC_plus_4_in, Circular_IE_Close_From_WB, // input signals
        Order_out, RegFile_Din_out, Write_Reg_num_out, Reg_Write_enable_out, HI_LO_Write_enable_out, ALU_result2_out, HI_Write_to_GPR_out, 
        LO_Write_to_GPR_out, Circular_ERET_To_WB, WB_NOINT_NextPC, WB_INT_PC_Choose, PC_plus_4_out, Circular_IE_Close_To_WB);
    input clk, rst, enable, Reg_Write_enable_in, HI_LO_Write_enable_in, HI_Write_to_GPR_in, LO_Write_to_GPR_in, MEM_WB_INT_PC_Choose;
    input [31:0]RegFile_Din_in, Order_in, ALU_result2_in, MEM_WB_NOINT_NextPC, PC_plus_4_in;
    input [4:0]Write_Reg_num_in;
    input Circular_ERET_From_WB, Circular_IE_Close_From_WB;
    output reg[31:0]RegFile_Din_out , Order_out, ALU_result2_out, WB_NOINT_NextPC, PC_plus_4_out;
    output reg[4:0]Write_Reg_num_out;
    output reg HI_LO_Write_enable_out, Reg_Write_enable_out, HI_Write_to_GPR_out, LO_Write_to_GPR_out, Circular_ERET_To_WB, 
                WB_INT_PC_Choose, Circular_IE_Close_To_WB;

    initial begin
        RegFile_Din_out<=0;     Write_Reg_num_out<=0;   Reg_Write_enable_out<=0;    Order_out<=0;
        HI_LO_Write_enable_out<=0;  ALU_result2_out<=0; HI_Write_to_GPR_out<=0;     LO_Write_to_GPR_out<=0;
        WB_NOINT_NextPC <= 0;   WB_INT_PC_Choose <= 0;  PC_plus_4_out <= 0;     Circular_IE_Close_To_WB <= 0;
    end

    always @(posedge clk) begin
        if(rst) begin   
            RegFile_Din_out<=0;     Write_Reg_num_out<=0;   Reg_Write_enable_out<=0;    Order_out<=0;
            HI_LO_Write_enable_out<=0;  ALU_result2_out<=0; HI_Write_to_GPR_out<=0;     LO_Write_to_GPR_out<=0;
            WB_INT_PC_Choose <= 0;  PC_plus_4_out <= 0;     Circular_IE_Close_To_WB <= 0;
        end
        else if(enable) begin
            RegFile_Din_out<=RegFile_Din_in;    Write_Reg_num_out<=Write_Reg_num_in;
            Reg_Write_enable_out<=Reg_Write_enable_in;  Order_out<=Order_in;
            HI_LO_Write_enable_out<=HI_LO_Write_enable_in;  ALU_result2_out<=ALU_result2_in;
            HI_Write_to_GPR_out<=HI_Write_to_GPR_in;     LO_Write_to_GPR_out<=LO_Write_to_GPR_in;
            Circular_ERET_To_WB <= Circular_ERET_From_WB;   WB_NOINT_NextPC <= MEM_WB_NOINT_NextPC;
            WB_INT_PC_Choose <= MEM_WB_INT_PC_Choose;   PC_plus_4_out <= PC_plus_4_in;
            Circular_IE_Close_To_WB <= Circular_IE_Close_From_WB;
        end
    end
endmodule
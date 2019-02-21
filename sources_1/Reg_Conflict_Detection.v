`timescale 1ns / 1ps

module Reg_Conflict_Detection(input R1_used, R2_used,
                            input [4:0]R1_in, R2_in, EX_Write_Reg, MEM_Write_Reg, 
                            input EX_Reg_Write, MEM_Reg_Write,
                            output conflict);
        //��⵽������أ���ر�PC_register��IF_IDʹ�ܶˣ�ͬʱ��ID_EX����
        assign conflict = (EX_Reg_Write & (R1_used&(EX_Write_Reg==R1_in) | R2_used&(EX_Write_Reg==R2_in))) |
                        (MEM_Reg_Write & (R1_used&(MEM_Write_Reg==R1_in) | R2_used&(MEM_Write_Reg==R2_in)));
endmodule
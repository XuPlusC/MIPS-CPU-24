`timescale 1ns / 1ps

module Reg_Conflict_Detection_Bypass(input R1_used, R2_used,    //R1�Ĵ�������Ч��R2�Ĵ�������Ч
                            input [4:0]R1_in, R2_in, EX_Write_Reg, MEM_Write_Reg, //��Ҫ��ȡ�ļĴ�����š�EX��MEM�׶���Ҫд��ļĴ������
                            input EX_Reg_Write, MEM_Reg_Write,  //EX��MEM�׶ε�ָ����Ҫд�Ĵ���
                            input EX_Sel, MEM_Sel, //0����д��RegFile��ֵΪALU����������1����д��RegFile��ֵΪ�ô���
                            output [1:0]conflict_A, conflict_B,//0����ԭֵ��1����MEM�׶ε�ALU_result��2����WB�׶ε�Read_data��3����WB�׶ε�ALU_result
                            output load_use);     //1������Load-Use������أ�����ͣPC_register��IF_ID������һ������
        wire EX_R1_same, EX_R2_same;
        wire MEM_R1_same, MEM_R2_same;
        
        assign EX_R1_same = R1_used&(R1_in!=0)&(EX_Write_Reg==R1_in);
        assign EX_R2_same = R2_used&(R2_in!=0)&(EX_Write_Reg==R2_in);
        assign MEM_R1_same = R1_used&(R1_in!=0)&(MEM_Write_Reg==R1_in);
        assign MEM_R2_same = R2_used&(R2_in!=0)&(MEM_Write_Reg==R2_in);
        
        assign conflict_A = ((~EX_Sel) & EX_Reg_Write & EX_R1_same)?2'b01:
                            ((MEM_Sel & MEM_Reg_Write & MEM_R1_same)?2'b10:
                            (((~MEM_Sel) & MEM_Reg_Write & MEM_R1_same)?2'b11:
                            2'b00));
        assign conflict_B = ((~EX_Sel) & EX_Reg_Write & EX_R2_same)?2'b01:
                            ((MEM_Sel & MEM_Reg_Write & MEM_R2_same)?2'b10:
                            (((~MEM_Sel) & MEM_Reg_Write & MEM_R2_same)?2'b11:
                            2'b00));
        
        assign load_use = EX_Sel & EX_Reg_Write & (EX_R1_same | EX_R2_same);
endmodule
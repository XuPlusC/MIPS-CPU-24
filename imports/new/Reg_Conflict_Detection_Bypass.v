`timescale 1ns / 1ps

module Reg_Conflict_Detection_Bypass(input R1_used, R2_used,    //R1寄存器读有效，R2寄存器读有效
                            input [4:0]R1_in, R2_in, EX_Write_Reg, MEM_Write_Reg, //需要读取的寄存器编号、EX和MEM阶段需要写入的寄存器编号
                            input EX_Reg_Write, MEM_Reg_Write,  //EX、MEM阶段的指令需要写寄存器
                            input EX_Sel, MEM_Sel, //0代表写入RegFile的值为ALU的运算结果，1代表写入RegFile的值为访存结果
                            output [1:0]conflict_A, conflict_B,//0代表原值，1代表MEM阶段的ALU_result，2代表WB阶段的Read_data，3代表WB阶段的ALU_result
                            output load_use);     //1代表发生Load-Use数据相关，需暂停PC_register和IF_ID，插入一个气泡
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
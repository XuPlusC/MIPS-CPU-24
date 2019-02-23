`timescale 1ns / 1ps

module Redirect_Pipeline_CPU(input clr, Go, clk, 
                        output [31:0]Leddata, Count_all, Count_branch, Count_jmp, Count_pipe, Count_load_use, Count_redirect);
        
        //ȡָ��IF�׶�
        wire [31:0]PC_in, PC_out;
        wire PC_enable;
        register PC_register(PC_in, PC_enable, clk, clr, PC_out);
        wire [31:0]PC_plus_4;
        assign PC_plus_4 = PC_out + 4;
        wire [31:0]Order;
        ROM get_Order(PC_out[11:0], 0, 2'b10, 0 ,1, clk, clr, 1, Order);
        wire IF_ID_clr, IF_ID_Enable;
        wire [31:0]IF_ID_Order_out, IF_ID_PC_plus_4_out;
        wire IF_ID_Enable_out;
        IF_ID pipeline1(Order, PC_plus_4, clk, IF_ID_clr, IF_ID_Enable, //�����ź�
                        IF_ID_Order_out, IF_ID_PC_plus_4_out, IF_ID_Enable_out);
        
        //����ID�׶�
        wire [5:0]OP, Func;
        assign OP = IF_ID_Order_out[31:26];
        assign Func = IF_ID_Order_out[5:0];
        wire [3:0]ALU_OP;
        wire Memtoreg, Memwrite, Alu_src, Regwrite, Syscall, Signedext, Regdst, Beq, Bne, Jr, Jmp, Jal, Shift, Lui, Blez, Bgtz, Bz;
        wire [1:0]Mode;
        wire Byte, Signext2, R1_used, R2_used;
        control get_control_sign(OP, Func, ALU_OP, Memtoreg, Memwrite, Alu_src, Regwrite, Syscall, Signedext, Regdst, Beq, Bne, Jr, Jmp, 
                Jal, Shift, Lui, Blez, Bgtz, Bz, Mode, Byte, Signext2, R1_used, R2_used);
        wire [4:0]R1_in, R2_in, W_in;
        wire [31:0]Din, R1_out, R2_out;
        wire RegFile_Regwrite;
        RegFile regfile1(R1_in, R2_in, W_in, Din, RegFile_Regwrite, clk, R1_out, R2_out);
        wire [31:0]imm;
        Extern extern1(IF_ID_Order_out, Signedext, imm);
        wire [4:0]WriteReg;
        wire ID_EX_clr, ID_EX_Enable;
        wire [3:0]ID_EX_ALU_OP_out;
        wire [1:0]ID_EX_Mode_out;
        wire [31:0]ID_EX_Order_out, ID_EX_PC_plus_4_out, ID_EX_RD1_out, ID_EX_RD1_out_temp, ID_EX_RD2_out, ID_EX_RD2_out_temp, ID_EX_imm;
        wire [4:0]ID_EX_WriteReg_out;
        wire ID_EX_Memtoreg_out, ID_EX_Memwrite_out, ID_EX_Alu_src_out, ID_EX_Regwrite_out, ID_EX_Syscall_out, ID_EX_Signedext_out, ID_EX_Regdst_out, ID_EX_Beq_out, ID_EX_Bne_out, ID_EX_Jr_out, ID_EX_Jmp_out, ID_EX_Jal_out, ID_EX_Shift_out, ID_EX_Lui_out, ID_EX_Blez_out, ID_EX_Bgtz_out, ID_EX_Bz_out, ID_EX_Byte_out, ID_EX_Signext2_out, ID_EX_R1_used_out, ID_EX_R2_used_out,
              ID_EX_Enable_out;
        wire [1:0]conflict_A, conflict_B, EX_conflict_A, EX_conflict_B;
        
        //2.22
        wire Syscall_to_Stop;
        assign Syscall_to_Stop = ID_EX_Syscall_out & ~(ID_EX_RD1_out == 34) & (~Go);   
              
        ID_EX pipeline2(ALU_OP, Memtoreg, Memwrite, Alu_src, Regwrite, Syscall, Signedext, Regdst, Beq, Bne, Jr, Jmp, Jal, Shift, Lui, Blez, Bgtz, Bz, Mode, conflict_A, conflict_B, Byte, Signext2, R1_used, R2_used,
                IF_ID_Order_out, IF_ID_PC_plus_4_out, R1_out, R2_out, imm, WriteReg, clk, ID_EX_clr, ID_EX_Enable, //�����ź�
                ID_EX_ALU_OP_out, ID_EX_Memtoreg_out, ID_EX_Memwrite_out, ID_EX_Alu_src_out, ID_EX_Regwrite_out, ID_EX_Syscall_out, ID_EX_Signedext_out, ID_EX_Regdst_out, ID_EX_Beq_out, ID_EX_Bne_out, ID_EX_Jr_out, ID_EX_Jmp_out, ID_EX_Jal_out, ID_EX_Shift_out, ID_EX_Lui_out, ID_EX_Blez_out, ID_EX_Bgtz_out, ID_EX_Bz_out, ID_EX_Mode_out, EX_conflict_A, EX_conflict_B, ID_EX_Byte_out, ID_EX_Signext2_out, ID_EX_R1_used_out, ID_EX_R2_used_out,
                ID_EX_Order_out, ID_EX_PC_plus_4_out, ID_EX_RD1_out_temp, ID_EX_RD2_out_temp, ID_EX_imm, ID_EX_WriteReg_out, ID_EX_Enable_out) ;  //����ź�;
        
        //ִ��EX�׶�
        wire [31:0]ALU_A, ALU_B, Result1, Result2;
        wire [4:0]shamt;
        wire OF, UOF, Equal;
        ALU alu1(ALU_A, ALU_B, ID_EX_ALU_OP_out, shamt, Result1, Result2, OF, UOF, Equal);
        wire [3:0]EX_MEM_ALU_OP_out;
        wire [1:0]EX_MEM_Mode_out;
        wire [31:0]EX_MEM_Order_out, EX_MEM_PC_plus_4_out, EX_MEM_ALU_Result1_out, EX_MEM_ALU_Result2_out, EX_MEM_RD2_out;
        wire [4:0]EX_MEM_WriteReg_out;
        wire EX_MEM_Memtoreg_out, EX_MEM_Memwrite_out, EX_MEM_Alu_src_out, EX_MEM_Regwrite_out, EX_MEM_Syscall_out, EX_MEM_Signedext_out, EX_MEM_Regdst_out, EX_MEM_Beq_out, EX_MEM_Bne_out, EX_MEM_Jr_out, EX_MEM_Jmp_out, EX_MEM_Jal_out, EX_MEM_Shift_out, EX_MEM_Lui_out, EX_MEM_Blez_out, EX_MEM_Bgtz_out, EX_MEM_Bz_out, EX_MEM_Byte_out, EX_MEM_Signext2_out, EX_MEM_R1_used_out, EX_MEM_R2_used_out,
        EX_MEM_ALU_OF_out, EX_MEM_ALU_UOF_out, EX_MEM_ALU_Equal_out, EX_MEM_Enable_out;
        EX_MEM pipeline3(ID_EX_ALU_OP_out, ID_EX_Memtoreg_out, ID_EX_Memwrite_out, ID_EX_Alu_src_out, ID_EX_Regwrite_out, ID_EX_Syscall_out, ID_EX_Signedext_out, ID_EX_Regdst_out, ID_EX_Beq_out, ID_EX_Bne_out, ID_EX_Jr_out, ID_EX_Jmp_out, ID_EX_Jal_out, ID_EX_Shift_out, ID_EX_Lui_out, ID_EX_Blez_out, ID_EX_Bgtz_out, ID_EX_Bz_out, ID_EX_Mode_out, ID_EX_Byte_out, ID_EX_Signext2_out, ID_EX_R1_used_out, ID_EX_R2_used_out,
                ID_EX_Order_out, ID_EX_PC_plus_4_out, Result1, Result2, OF, UOF, Equal, ID_EX_RD2_out, ID_EX_WriteReg_out, clk, clr, 1, //�����ź�
                EX_MEM_ALU_OP_out, EX_MEM_Memtoreg_out, EX_MEM_Memwrite_out, EX_MEM_Alu_src_out, EX_MEM_Regwrite_out, EX_MEM_Syscall_out, EX_MEM_Signedext_out, EX_MEM_Regdst_out, EX_MEM_Beq_out, EX_MEM_Bne_out, EX_MEM_Jr_out, EX_MEM_Jmp_out, EX_MEM_Jal_out, EX_MEM_Shift_out, EX_MEM_Lui_out, EX_MEM_Blez_out, EX_MEM_Bgtz_out, EX_MEM_Bz_out, EX_MEM_Mode_out, EX_MEM_Byte_out, EX_MEM_Signext2_out, EX_MEM_R1_used_out, EX_MEM_R2_used_out,
                EX_MEM_Order_out, EX_MEM_PC_plus_4_out, EX_MEM_ALU_Result1_out, EX_MEM_ALU_Result2_out, EX_MEM_ALU_OF_out, EX_MEM_ALU_UOF_out, EX_MEM_ALU_Equal_out, EX_MEM_RD2_out, EX_MEM_WriteReg_out, EX_MEM_Enable_out);
         //����׶Ρ�ִ�н׶Ρ��ô�׶ε�ָ��֮�����������ؼ��
        wire [4:0]EX_Write_Reg, MEM_Write_Reg;
        wire EX_Reg_Write, MEM_Reg_Write;
        assign EX_Write_Reg = ID_EX_WriteReg_out;
        assign EX_Reg_Write = ID_EX_Regwrite_out;
        wire Load_use;   //һ������load_use������أ���ر�PC_register��IF_IDʹ�ܶˣ�����ID_EX����
        Reg_Conflict_Detection_Bypass detection(R1_used, R2_used, R1_in, R2_in, EX_Write_Reg, MEM_Write_Reg, EX_Reg_Write, MEM_Reg_Write, ID_EX_Memtoreg_out, EX_MEM_Memtoreg_out, conflict_A, conflict_B, Load_use);
        
        //�ô�MEM�׶�
        wire [31:0]mem;
        RAM RAM1(EX_MEM_ALU_Result1_out[11:0], EX_MEM_RD2_out, EX_MEM_Mode_out, EX_MEM_Memwrite_out, 1, clk, clr, 1, mem);
        wire [3:0]MEM_WB_ALU_OP_out;
        wire [1:0]MEM_WB_Mode_out;
        wire [31:0]MEM_WB_Order_out, MEM_WB_PC_plus_4_out, MEM_WB_ALU_Result1_out, MEM_WB_ALU_Result2_out, MEM_WB_mem_out;
        wire [4:0]MEM_WB_WriteReg_out;
        wire MEM_WB_Memtoreg_out, MEM_WB_Memwrite_out, MEM_WB_Alu_src_out, MEM_WB_Regwrite_out, MEM_WB_Syscall_out, MEM_WB_Signedext_out, MEM_WB_Regdst_out, MEM_WB_Beq_out, MEM_WB_Bne_out, MEM_WB_Jr_out, MEM_WB_Jmp_out, MEM_WB_Jal_out, MEM_WB_Shift_out, MEM_WB_Lui_out, MEM_WB_Blez_out, MEM_WB_Bgtz_out, MEM_WB_Bz_out, MEM_WB_Byte_out, MEM_WB_Signext2_out, MEM_WB_R1_used_out, MEM_WB_R2_used_out,
            MEM_WB_ALU_OF_out, MEM_WB_ALU_UOF_out, MEM_WB_ALU_Equal_out, MEM_WB_Enable_out;
        MEM_WB pipeline4(EX_MEM_ALU_OP_out, EX_MEM_Memtoreg_out, EX_MEM_Memwrite_out, EX_MEM_Alu_src_out, EX_MEM_Regwrite_out, EX_MEM_Syscall_out, EX_MEM_Signedext_out, EX_MEM_Regdst_out, EX_MEM_Beq_out, EX_MEM_Bne_out, EX_MEM_Jr_out, EX_MEM_Jmp_out, EX_MEM_Jal_out, EX_MEM_Shift_out, EX_MEM_Lui_out, EX_MEM_Blez_out, EX_MEM_Bgtz_out, EX_MEM_Bz_out, EX_MEM_Mode_out, EX_MEM_Byte_out, EX_MEM_Signext2_out, EX_MEM_R1_used_out, EX_MEM_R2_used_out,
                EX_MEM_Order_out, EX_MEM_PC_plus_4_out, EX_MEM_ALU_Result1_out, EX_MEM_ALU_Result2_out, EX_MEM_ALU_OF_out, EX_MEM_ALU_UOF_out, EX_MEM_ALU_Equal_out, mem, EX_MEM_WriteReg_out, clk, clr, 1,  //�����ź�
                MEM_WB_ALU_OP_out, MEM_WB_Memtoreg_out, MEM_WB_Memwrite_out, MEM_WB_Alu_src_out, MEM_WB_Regwrite_out, MEM_WB_Syscall_out, MEM_WB_Signedext_out, MEM_WB_Regdst_out, MEM_WB_Beq_out, MEM_WB_Bne_out, MEM_WB_Jr_out, MEM_WB_Jmp_out, MEM_WB_Jal_out, MEM_WB_Shift_out, MEM_WB_Lui_out, MEM_WB_Blez_out, MEM_WB_Bgtz_out, MEM_WB_Bz_out, MEM_WB_Mode_out, MEM_WB_Byte_out, MEM_WB_Signext2_out, MEM_WB_R1_used_out, MEM_WB_R2_used_out,
                MEM_WB_Order_out, MEM_WB_PC_plus_4_out, MEM_WB_ALU_Result1_out, MEM_WB_ALU_Result2_out, MEM_WB_ALU_OF_out, MEM_WB_ALU_UOF_out, MEM_WB_ALU_Equal_out, MEM_WB_mem_out, MEM_WB_WriteReg_out, MEM_WB_Enable_out);
        assign MEM_Write_Reg = EX_MEM_WriteReg_out;
        assign MEM_Reg_Write = EX_MEM_Regwrite_out;
        
         //ID_EX_RD1_out, ID_EX_RD2_out�ض���
        Mux_2 #(32) mux_get_ID_EX_RD1_out(ID_EX_RD1_out_temp, EX_MEM_ALU_Result1_out, MEM_WB_mem_out, MEM_WB_ALU_Result1_out, EX_conflict_A, ID_EX_RD1_out);
        Mux_2 #(32) mux_get_ID_EX_RD2_out(ID_EX_RD2_out_temp, EX_MEM_ALU_Result1_out, MEM_WB_mem_out, MEM_WB_ALU_Result1_out, EX_conflict_B, ID_EX_RD2_out);

        //д��WB�׶�
        Data_to_Din Din1 (MEM_WB_Byte_out, MEM_WB_Signext2_out, MEM_WB_mem_out, MEM_WB_ALU_Result1_out, MEM_WB_PC_plus_4_out, MEM_WB_Jal_out, MEM_WB_Memtoreg_out, Din);
        assign RegFile_Regwrite = MEM_WB_Regwrite_out;
        assign W_in = MEM_WB_WriteReg_out;
         
        //PC_enable
        wire PC_enable_temp;
        PCenable PC_enable1 (ID_EX_RD1_out, ID_EX_Syscall_out, Go, clk, PC_enable_temp);
        assign PC_enable = PC_enable_temp & (~Load_use);
        
        //ext18
        wire [15:0]temp;
        wire [31:0]ext18;
        assign temp = ID_EX_imm[15]?16'hFFFF:16'h0;
        assign ext18 = {temp, ID_EX_imm[15:0]}<<2;
        //branch
        wire branch;
        Branch branch1 (ID_EX_Bne_out, ID_EX_Beq_out, ID_EX_Blez_out, ID_EX_Bgtz_out, ID_EX_Bz_out, Equal, ID_EX_Order_out[16], ID_EX_RD1_out, branch);
        //��ָ֧��ɹ�ʱʹIF_ID��ID_EX�ر�ʹ�ܶˣ�����IF��ID�׶ε���Чָ�����������
        assign IF_ID_clr = clr | branch | ID_EX_Jmp_out;
        assign IF_ID_Enable = ~(Syscall_to_Stop | Load_use);
        assign ID_EX_clr = clr | branch | ID_EX_Jmp_out | Load_use;
        assign ID_EX_Enable = (~(branch | ID_EX_Jmp_out)) & (~Syscall_to_Stop);
        
        //PC_data
        PC_data PC_data1 (PC_plus_4, ext18, ID_EX_Order_out[25:0], branch, ID_EX_Jmp_out, ID_EX_Jr_out, ID_EX_RD1_out, ID_EX_PC_plus_4_out, PC_in);

        //shamt
        shamt_input shamt1 (ID_EX_Order_out, ID_EX_RD1_out, ID_EX_Shift_out, ID_EX_Lui_out, shamt);

        //ID_to_reg
        Path_ROM_to_Reg path1(IF_ID_Order_out, Jal, Regdst, Syscall, R1_in, R2_in, WriteReg);
        
        //aluA, aluB
        assign ALU_A = ID_EX_RD1_out;
        Mux_1 #(32) mux_alu_ALU_B (ID_EX_RD2_out, ID_EX_imm, ID_EX_Alu_src_out, ALU_B);

        //count EX�׶�
        wire pipe, redirect;
        assign pipe = (ID_EX_Order_out==0)?1:0;
        assign redirect = ~(EX_conflict_A==0 | EX_conflict_B==0);
        Counter_circle counter_circle1(clk, clr, branch, ID_EX_Jmp_out, ID_EX_Syscall_out, pipe, Load_use, redirect,
                ID_EX_RD1_out, Count_all, Count_branch, Count_jmp, Count_pipe, Count_load_use, Count_redirect);

        //LedData EX�׶�
        LedData led1(ID_EX_Syscall_out, ID_EX_RD1_out, ID_EX_RD2_out, clk, clr, Leddata);

endmodule

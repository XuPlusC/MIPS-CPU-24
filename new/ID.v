`timescale 1ns / 1ps

module ID(clk, Order, Din, W_in, EX_Write_Reg_num, MEM_Write_Reg_num, Reg_Write_enable, EX_Reg_Write_enable, MEM_Reg_Write_enable, EX_Memread, MEM_Memread,
        ALU_OP, Memread, Memwrite, Regwrite, Syscall, Beq, Bne, conflict_sel_A, conflict_sel_B, EX_HI_Write_to_GPR, EX_LO_Write_to_GPR, EX_MTC0, EX_MFC0,
            Jr, Jmp, Jal, Shift, Lui, Blez, Bgtz, Bz, Mode, Byte, R1_out, ID_R2_out, imm, Write_Reg_num, load_use,
            Signext2, R1_used, R2_used, HI_LO_Write_enable, HI_Write_to_GPR, LO_Write_to_GPR, MTC0, MFC0);
    input [31:0]Order, Din;
    input [4:0]W_in, EX_Write_Reg_num, MEM_Write_Reg_num;
    input Reg_Write_enable, clk, EX_Reg_Write_enable, MEM_Reg_Write_enable, EX_Memread, MEM_Memread, EX_HI_Write_to_GPR, EX_LO_Write_to_GPR, EX_MTC0, EX_MFC0;
    output [31:0]R1_out, ID_R2_out, imm;
    output [4:0]Write_Reg_num;
    output [3:0]ALU_OP;
    output [1:0]conflict_sel_A, conflict_sel_B, Mode;
    output load_use, Memread, Memwrite, Regwrite, Syscall, Beq, Bne, HI_LO_Write_enable, HI_Write_to_GPR, LO_Write_to_GPR,
                    Jr, Jmp, Jal, Shift, Lui, Blez, Bgtz, Bz, Byte, Signext2, R1_used, R2_used, MTC0, MFC0;
            
    wire Alu_src, Signedext, Regdst;
    wire MFC0 ; 	///////2.25
    //������
    control get_control_sign(Order[31:26], Order[5:0], Order[25:21], //OP��FUNC/////////////////2.25
            ALU_OP, Memread, Memwrite, Alu_src, Regwrite, Syscall, Signedext, Regdst, Beq, Bne, 
            Jr, Jmp, Jal, Shift, Lui, Blez, Bgtz, Bz, Mode, Byte, 
            Signext2, R1_used, R2_used, HI_LO_Write_enable, HI_Write_to_GPR, LO_Write_to_GPR, MFC0, MTC0); 	///////2.25);
    
    wire [4:0]R1_in, R2_in;
    //��ָ��������� ͨ�üĴ����������ź�
    Path_ROM_to_Reg get_RegFile_input(Order, Jal, Regdst, Syscall, R1_in, R2_in, Write_Reg_num);
    
    wire [31:0]R2_out;
    //ͨ�üĴ�����
    RegFile GPR(R1_in, R2_in, W_in, Din, Reg_Write_enable, clk, R1_out, R2_out);

    //��������չ
    Extern get_imm(Order, Signedext, imm);
    
    //ѡ��Ӧ�ô���ALU_B������
    Mux_1 #(32) mux_ALU_B(R2_out, imm, Alu_src, ID_R2_out);

    //�ж�������أ����Load_use���ض���ѡ���ź�
    Reg_Conflict_Detection_Bypass detection(R1_used, R2_used, R1_in, R2_in, EX_Write_Reg_num, MEM_Write_Reg_num,
            EX_Reg_Write_enable, MEM_Reg_Write_enable, EX_Memread | EX_HI_Write_to_GPR | EX_LO_Write_to_GPR | EX_MFC0,  // EX_MTC0
            MEM_Memread, conflict_sel_A, conflict_sel_B, load_use);
endmodule

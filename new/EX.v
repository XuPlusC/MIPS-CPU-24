`timescale 1ns / 1ps

module EX(Order, RD1, RD2, MEM_ALU_result, WB_RegFile_Din, Shift, Lui, Bne, Beq, Blez, Bgtz, Bz, Jmp, Jr, ALU_OP, Sel_A, Sel_B, IF_PC_plus_4, PC_plus_4, imm, IntRequest, Int_NextPC,
        IF_nextPC, A, B, Result1, Result2, branch);
    input [31:0]Order, RD1, RD2, MEM_ALU_result, WB_RegFile_Din;
    input Shift, Lui, Bne, Beq, Blez, Bgtz, Bz, Jmp, Jr;
    input [3:0]ALU_OP;
    input [1:0]Sel_A, Sel_B;
    input [31:0]IF_PC_plus_4, PC_plus_4, imm;
    ///////
    input IntRequest;
    input [31:0]Int_NextPC;
    ///////
    output [31:0]IF_nextPC;
    output [31:0]A, B, Result1, Result2;
    output branch;

    wire [4:0]shamt;
    wire OF, UOF, Equal;
    //���ALU����λshamt�ź�
    shamt_input get_shamt(Order, RD1, Shift, Lui, shamt);

    //ALU_A��ALU_B�ض���
    Mux_2 #(32) mux_get_A(RD1, MEM_ALU_result, WB_RegFile_Din, WB_RegFile_Din, Sel_A, A);
    Mux_2 #(32) mux_get_B(RD2, MEM_ALU_result, WB_RegFile_Din, WB_RegFile_Din, Sel_B, B);

    //ALU����
    ALU alu(A, B, ALU_OP, shamt, Result1, Result2, OF, UOF, Equal);
    
    //�жϷ�֧�ź�
    Branch get_branch(Bne, Beq, Blez, Bgtz, Bz, Equal, Order[16], A, branch);

    wire [31:0]NextPC_No_Interruption;
    //���з�֧��ת������PCֵ
    PC_data PC_data1 (IF_PC_plus_4, {(imm[15]?16'hFFFF:16'h0), imm[15:0]}<<2, 
        Order[25:0], branch, Jmp, Jr, A, PC_plus_4, NextPC_No_Interruption);

    assign IF_nextPC = IntRequest?Int_NextPC:NextPC_No_Interruption;
endmodule
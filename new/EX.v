`timescale 1ns / 1ps

module EX(Order, RD1, RD2, MEM_ALU_result, WB_RegFile_Din, Shift, Lui, Bne, Beq, Blez, Bgtz, Bz, Jmp, Jr, 
        ALU_OP, Sel_A, Sel_B, IF_PC_plus_4, PC_plus_4, imm, IntRequest, Int_NextPC, EPC_in, ERET, // input signal
        IF_nextPC, A, B, Result1, Result2, branch, EX_NOINT_NextPC, EX_MEM_INT_PC_Choose);
    input [31:0]Order, RD1, RD2, MEM_ALU_result, WB_RegFile_Din;
    input Shift, Lui, Bne, Beq, Blez, Bgtz, Bz, Jmp, Jr;
    input [3:0]ALU_OP;
    input [1:0]Sel_A, Sel_B;
    input [31:0]IF_PC_plus_4, PC_plus_4, imm;
    ///////
    input IntRequest, ERET;
    input [31:0]Int_NextPC, EPC_in;
    ///////
    output [31:0]IF_nextPC;
    output [31:0]A, B, Result1, Result2;
    output branch, EX_MEM_INT_PC_Choose;
    output [31:0]EX_NOINT_NextPC;

    wire [4:0]shamt;
    wire OF, UOF, Equal;
    //获得ALU的移位shamt信号
    shamt_input get_shamt(Order, RD1, Shift, Lui, shamt);

    //ALU_A和ALU_B重定向
    Mux_2 #(32) mux_get_A(RD1, MEM_ALU_result, WB_RegFile_Din, WB_RegFile_Din, Sel_A, A);
    Mux_2 #(32) mux_get_B(RD2, MEM_ALU_result, WB_RegFile_Din, WB_RegFile_Din, Sel_B, B);

    //ALU计算
    ALU alu(A, B, ALU_OP, shamt, Result1, Result2, OF, UOF, Equal);
    
    //判断分支信号
    Branch get_branch(Bne, Beq, Blez, Bgtz, Bz, Equal, Order[16], A, branch);

    //进行分支跳转，更新PC值
    PC_data PC_data1 (IF_PC_plus_4, {(imm[15]?16'hFFFF:16'h0), imm[15:0]}<<2, 
        Order[25:0], branch, Jmp, Jr, A, PC_plus_4, EX_NOINT_NextPC);

    assign IF_nextPC = IntRequest?Int_NextPC:
                        (ERET)?EPC_in:EX_NOINT_NextPC;
    assign EX_MEM_INT_PC_Choose = branch | Jmp | Jr;
endmodule

`timescale 1ns / 1ps

module Redirect_Pipeline_CPU(input rst, Go, clk, 
                        output [31:0]Leddata, Count_all, Count_branch, Count_jmp, Count_pipe, Count_load_use, Count_redirect);
    
    wire [31:0]IF_nextPC, EX_A, IF_PC_out, IF_PC_plus_4, IF_Order;
    wire ID_EX_Syscall_out, ID_Load_use;
    IF cpu_if(.PC_in(IF_nextPC), .PC_enable(((EX_A==32'h00000022) | (~ID_EX_Syscall_out) | Go) & (~ID_Load_use)),
        .clk(clk), .rst(rst), //输入信号
        .PC_plus_4(IF_PC_plus_4), .Order(IF_Order));
    
    wire Syscall_to_Stop;
    assign Syscall_to_Stop = ID_EX_Syscall_out & ~(EX_A == 34) & (~Go);
    
    wire EX_branch, ID_EX_jmp_out;
    wire [31:0]IF_ID_Order_out, IF_ID_PC_plus_4_out;
    IF_ID pipeline1(.clk(clk), .rst(rst | EX_branch | ID_EX_jmp_out), .enable((~(Syscall_to_Stop | ID_Load_use))), 
        .Order_in(IF_Order),.PC_plus_4_in(IF_PC_plus_4),    //输入信号
        .PC_plus_4_out(IF_ID_PC_plus_4_out), .Order_out(IF_ID_Order_out));
    
    wire [31:0]WB_RegFile_Din, ID_R1_out, ID_R2_out, ID_imm;
    wire [4:0]MEM_WB_Write_Reg_num_out, ID_EX_Write_Reg_num_out, EX_MEM_Write_Reg_num_out, ID_Write_Reg_num;
    wire [3:0]ID_ALU_OP;
    wire [1:0]ID_conflict_sel_A, ID_conflict_sel_B, ID_Mode;
    wire MEM_WB_Reg_Write_enable_out, ID_EX_Reg_Write_enable_out, EX_MEM_Reg_Write_enable_out, ID_Shift, ID_lui, ID_Bne,
        ID_Beq, ID_Blez, ID_Bgtz, ID_Bz, ID_jmp, ID_Jr, ID_Syscall, ID_Memwrite, ID_Memread, ID_Byte, ID_Signext2,
        ID_Jal, ID_Reg_Write_enable, ID_R1_used, ID_R2_used, ID_EX_Memread_out, EX_MEM_Memread_out, ID_HI_LO_Write_enable,
        ID_HI_Write_to_GPR, ID_LO_Write_to_GPR, ID_EX_HI_Write_to_GPR_out, ID_EX_LO_Write_to_GPR_out;
    ID cpu_id(.Order(IF_ID_Order_out), .Din(WB_RegFile_Din), .W_in(MEM_WB_Write_Reg_num_out),
        .EX_Write_Reg_num(ID_EX_Write_Reg_num_out), .MEM_Write_Reg_num(EX_MEM_Write_Reg_num_out),
        .Reg_Write_enable(MEM_WB_Reg_Write_enable_out), .clk(clk), .EX_Reg_Write_enable(ID_EX_Reg_Write_enable_out),
        .MEM_Reg_Write_enable(EX_MEM_Reg_Write_enable_out),  .EX_Memread(ID_EX_Memread_out), .MEM_Memread(EX_MEM_Memread_out),
        .EX_HI_Write_to_GPR(ID_EX_HI_Write_to_GPR_out), .EX_LO_Write_to_GPR(ID_EX_LO_Write_to_GPR_out),//输入信号
        .R1_out(ID_R1_out), .ID_R2_out(ID_R2_out), .imm(ID_imm), .Write_Reg_num(ID_Write_Reg_num), .conflict_sel_A(ID_conflict_sel_A),
        .conflict_sel_B(ID_conflict_sel_B), .load_use(ID_Load_use), .Shift(ID_Shift), .Lui(ID_lui), .Bne(ID_Bne), 
        .Beq(ID_Beq), .Blez(ID_Blez), .Bgtz(ID_Bgtz), .Bz(ID_Bz), .Jmp(ID_jmp), .Jr(ID_Jr), .Syscall(ID_Syscall), 
        .ALU_OP(ID_ALU_OP), .Mode(ID_Mode), .Memwrite(ID_Memwrite), .Memread(ID_Memread), .Byte(ID_Byte), .Signext2(ID_Signext2),
        .Jal(ID_Jal), .R1_used(ID_R1_used), .R2_used(ID_R2_used), .Regwrite(ID_Reg_Write_enable), .HI_LO_Write_enable(ID_HI_LO_Write_enable),
        .HI_Write_to_GPR(ID_HI_Write_to_GPR), .LO_Write_to_GPR(ID_LO_Write_to_GPR));

    wire ID_EX_Shift_out, ID_EX_Lui_out, ID_EX_Bne_out, ID_EX_Beq_out, ID_EX_Blez_out, ID_EX_Bgtz_out, ID_EX_Bz_out,
        ID_EX_Jr_out, ID_EX_Memwrite_out, ID_EX_Byte_out, ID_EX_Signext2_out, ID_EX_Jal_out, ID_EX_HI_LO_Write_enable_out;
    wire [31:0]ID_EX_Order_out, ID_EX_RD1_out, ID_EX_RD2_out, ID_EX_imm_out, ID_EX_PC_plus_4_out;
    wire [3:0]ID_EX_ALU_OP_out;
    wire [1:0]ID_EX_Mode_out, ID_EX_conflict_sel_A_out, ID_EX_conflict_sel_B_out;
    ID_EX pipeline2(.clk(clk), .rst(rst | EX_branch | ID_EX_jmp_out | ID_Load_use), .enable((~(EX_branch | ID_EX_jmp_out | Syscall_to_Stop))),
        .Order_in(IF_ID_Order_out), .RD1_in(ID_R1_out), .RD2_in(ID_R2_out), .Shift_in(ID_Shift), .Lui_in(ID_lui), 
        .imm_in(ID_imm), .Bne_in(ID_Bne), .Beq_in(ID_Beq), .Blez_in(ID_Blez), 
        .Bgtz_in(ID_Bgtz), .Bz_in(ID_Bz), .Jmp_in(ID_jmp), .Jr_in(ID_Jr),
        .ALU_OP_in(ID_ALU_OP), .Sel_A_in(ID_conflict_sel_A), .Sel_B_in(ID_conflict_sel_B),
        .PC_plus_4_in(IF_ID_PC_plus_4_out), .Mode_in(ID_Mode), .Memwrite_in(ID_Memwrite),
        .Memread_in(ID_Memread), .Byte_in(ID_Byte), .Signext2_in(ID_Signext2), 
        .Jal_in(ID_Jal), .Write_Reg_num_in(ID_Write_Reg_num), .Reg_Write_enable_in(ID_Reg_Write_enable), .Syscall_in(ID_Syscall),
        .HI_LO_Write_enable_in(ID_HI_LO_Write_enable), .HI_Write_to_GPR_in(ID_HI_Write_to_GPR), .LO_Write_to_GPR_in(ID_LO_Write_to_GPR),//输入信号
        
        .Order_out(ID_EX_Order_out), .RD1_out(ID_EX_RD1_out), .RD2_out(ID_EX_RD2_out), .Shift_out(ID_EX_Shift_out), .Lui_out(ID_EX_Lui_out), 
        .imm_out(ID_EX_imm_out), .Bne_out(ID_EX_Bne_out), .Beq_out(ID_EX_Beq_out), .Blez_out(ID_EX_Blez_out), 
        .Bgtz_out(ID_EX_Bgtz_out), .Bz_out(ID_EX_Bz_out), .Jmp_out(ID_EX_jmp_out), .Jr_out(ID_EX_Jr_out),
        .ALU_OP_out(ID_EX_ALU_OP_out), .Sel_A_out(ID_EX_conflict_sel_A_out), .Sel_B_out(ID_EX_conflict_sel_B_out),
        .PC_plus_4_out(ID_EX_PC_plus_4_out), .Mode_out(ID_EX_Mode_out), .Memwrite_out(ID_EX_Memwrite_out),
         .Memread_out(ID_EX_Memread_out), .Byte_out(ID_EX_Byte_out), .Signext2_out(ID_EX_Signext2_out), 
         .Jal_out(ID_EX_Jal_out), .Write_Reg_num_out(ID_EX_Write_Reg_num_out), .Reg_Write_enable_out(ID_EX_Reg_Write_enable_out), 
         .Syscall_out(ID_EX_Syscall_out), .HI_LO_Write_enable_out(ID_EX_HI_LO_Write_enable_out),
         .HI_Write_to_GPR_out(ID_EX_HI_Write_to_GPR_out), .LO_Write_to_GPR_out(ID_EX_LO_Write_to_GPR_out));
    
    wire [31:0]EX_B, EX_ALU_result, EX_ALU_result2, EX_MEM_ALU_result_out;
    EX cpu_ex(.Order(ID_EX_Order_out), .RD1(ID_EX_RD1_out), .RD2(ID_EX_RD2_out), .MEM_ALU_result(EX_MEM_ALU_result_out), 
        .WB_RegFile_Din(WB_RegFile_Din), .Shift(ID_EX_Shift_out), .Lui(ID_EX_Lui_out), 
        .Bne(ID_EX_Bne_out), .Beq(ID_EX_Beq_out), .Blez(ID_EX_Blez_out), .Bgtz(ID_EX_Bgtz_out), 
        .Bz(ID_EX_Bz_out), .Jmp(ID_EX_jmp_out), .Jr(ID_EX_Jr_out),
        .ALU_OP(ID_EX_ALU_OP_out), .Sel_A(ID_EX_conflict_sel_A_out), .Sel_B(ID_EX_conflict_sel_B_out), 
        .IF_PC_plus_4(IF_PC_plus_4), .PC_plus_4(ID_EX_PC_plus_4_out), .imm(ID_EX_imm_out),  //输入信号
        .IF_nextPC(IF_nextPC), .A(EX_A), .B(EX_B), .Result1(EX_ALU_result), .Result2(EX_ALU_result2), .branch(EX_branch));

    wire EX_MEM_Jal_out, EX_MEM_Signext2_out, EX_MEM_Byte_out, EX_MEM_Memwrite_out, EX_MEM_HI_LO_Write_enable_out,
        EX_MEM_HI_Write_to_GPR_out, EX_MEM_LO_Write_to_GPR_out;
    wire [1:0]EX_MEM_Mode_out;
    wire [31:0]EX_MEM_PC_plus_4_out, EX_MEM_B_out, EX_MEM_Order_out, EX_MEM_ALU_result2_out;
    EX_MEM pipeline3(.clk(clk), .rst(rst), .enable(1'b1), .Order_in(ID_EX_Order_out), .ALU_result_in(EX_ALU_result), .B_in(EX_B),
        .PC_plus_4_in(ID_EX_PC_plus_4_out), .Mode_in(ID_EX_Mode_out), .Memwrite_in(ID_EX_Memwrite_out), .Memread_in(ID_EX_Memread_out),
        .Byte_in(ID_EX_Byte_out), .Signext2_in(ID_EX_Signext2_out), .Jal_in(ID_EX_Jal_out), 
        .Write_Reg_num_in(ID_EX_Write_Reg_num_out), .Reg_Write_enable_in(ID_EX_Reg_Write_enable_out),
        .HI_LO_Write_enable_in(ID_EX_HI_LO_Write_enable_out), .ALU_result2_in(EX_ALU_result2),
        .HI_Write_to_GPR_in(ID_EX_HI_Write_to_GPR_out), .LO_Write_to_GPR_in(ID_EX_LO_Write_to_GPR_out),  //输入信号
        .Order_out(EX_MEM_Order_out), .ALU_result_out(EX_MEM_ALU_result_out), .B_out(EX_MEM_B_out), .PC_plus_4_out(EX_MEM_PC_plus_4_out),
        .Mode_out(EX_MEM_Mode_out), .Memwrite_out(EX_MEM_Memwrite_out), .Memread_out(EX_MEM_Memread_out), .Byte_out(EX_MEM_Byte_out), 
        .Signext2_out(EX_MEM_Signext2_out), .Jal_out(EX_MEM_Jal_out), .Write_Reg_num_out(EX_MEM_Write_Reg_num_out), 
        .Reg_Write_enable_out(EX_MEM_Reg_Write_enable_out), .HI_LO_Write_enable_out(EX_MEM_HI_LO_Write_enable_out),
        .ALU_result2_out(EX_MEM_ALU_result2_out), .HI_Write_to_GPR_out(EX_MEM_HI_Write_to_GPR_out), .LO_Write_to_GPR_out(EX_MEM_LO_Write_to_GPR_out));

    wire [31:0]MEM_RegFile_Din;
    MEM cpu_mem(.clk(clk), .rst(rst), .Din(EX_MEM_B_out), .Order(EX_MEM_Order_out), .ALU_result(EX_MEM_ALU_result_out), 
        .PC_plus_4(EX_MEM_PC_plus_4_out), .Mode(EX_MEM_Mode_out), .Write_enable(EX_MEM_Memwrite_out), 
        .Sel(1'b1), .Read_enable(EX_MEM_Memread_out), .Byte(EX_MEM_Byte_out), .Signext2(EX_MEM_Signext2_out), 
        .Jal(EX_MEM_Jal_out),   //输入信号
        .RegFile_Din(MEM_RegFile_Din));
    
    wire [31:0]MEM_WB_Order_out, MEM_WB_ALU_result2_out, MEM_WB_RegFile_Din_out;
    wire MEM_WB_HI_LO_Write_enable_out, MEM_WB_HI_Write_to_GPR_out, MEM_WB_LO_Write_to_GPR_out;
    MEM_WB pipeline4(.clk(clk), .rst(rst), .enable(1'b1), .Order_in(EX_MEM_Order_out), .RegFile_Din_in(MEM_RegFile_Din),
        .Write_Reg_num_in(EX_MEM_Write_Reg_num_out), .Reg_Write_enable_in(EX_MEM_Reg_Write_enable_out),
        .HI_LO_Write_enable_in(EX_MEM_HI_LO_Write_enable_out), .ALU_result2_in(EX_MEM_ALU_result2_out),
        .HI_Write_to_GPR_in(EX_MEM_HI_Write_to_GPR_out), .LO_Write_to_GPR_in(EX_MEM_LO_Write_to_GPR_out),     //输入信号
        .Order_out(MEM_WB_Order_out), .RegFile_Din_out(MEM_WB_RegFile_Din_out), .Write_Reg_num_out(MEM_WB_Write_Reg_num_out), 
        .Reg_Write_enable_out(MEM_WB_Reg_Write_enable_out), .HI_LO_Write_enable_out(MEM_WB_HI_LO_Write_enable_out),
        .ALU_result2_out(MEM_WB_ALU_result2_out), .HI_Write_to_GPR_out(MEM_WB_HI_Write_to_GPR_out), .LO_Write_to_GPR_out(MEM_WB_LO_Write_to_GPR_out));
    
    wire [31:0]WB_HI_out, WB_LO_out;
    WB cpu_wb(.clk(clk), .rst(rst), .Order(MEM_WB_Order_out), .RegFile_Din(MEM_WB_RegFile_Din_out), .Write_Reg_num(MEM_WB_Write_Reg_num_out), 
        .Reg_Write_enable(MEM_WB_Reg_Write_enable_out), .HI_LO_Write_enable(MEM_WB_HI_LO_Write_enable_out), 
        .HI_in(MEM_WB_ALU_result2_out), .HI_Write_to_GPR(MEM_WB_HI_Write_to_GPR_out), .LO_Write_to_GPR(MEM_WB_LO_Write_to_GPR_out),   //输入信号
        .RegFile_Din_out(WB_RegFile_Din));
    
    //count EX阶段
    wire pipe, redirect;
    assign pipe = (ID_EX_Order_out==0)?1:0;
    assign redirect = ~(ID_EX_conflict_sel_A_out==0 | ID_EX_conflict_sel_B_out==0);
    Counter_circle counter_circle1(clk, rst, EX_branch, ID_EX_jmp_out, ID_EX_Syscall_out, pipe, ID_Load_use, redirect,
            EX_A, Count_all, Count_branch, Count_jmp, Count_pipe, Count_load_use, Count_redirect);

    //LedData EX阶段
    LedData led1(ID_EX_Syscall_out, EX_A, EX_B, clk, rst, Leddata);
endmodule

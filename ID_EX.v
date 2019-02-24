`timescale 1ns / 1ps

module ID_EX(clk, rst, enable, 
    Order_in, RD1_in, RD2_in, Shift_in, Lui_in, Bne_in, Beq_in, Blez_in, Bgtz_in, Bz_in, Jmp_in, Jr_in, ALU_OP_in, Sel_A_in, Sel_B_in, 
    PC_plus_4_in, imm_in, Mode_in, Memwrite_in, Memread_in, Byte_in, Signext2_in, Jal_in, Write_Reg_num_in, Reg_Write_enable_in, 
    Syscall_in, HI_LO_Write_enable_in, HI_Write_to_GPR_in, LO_Write_to_GPR_in,
    
    Order_out, RD1_out, RD2_out, Shift_out, Lui_out, Bne_out, Beq_out, Blez_out, Bgtz_out, Bz_out, Jmp_out, Jr_out, ALU_OP_out, 
    Sel_A_out, Sel_B_out, PC_plus_4_out, imm_out, Mode_out, Memwrite_out, Memread_out, Byte_out, Signext2_out, Jal_out, 
    Write_Reg_num_out, Reg_Write_enable_out, Syscall_out, HI_LO_Write_enable_out, HI_Write_to_GPR_out, LO_Write_to_GPR_out);
    
    input clk, rst, enable, Shift_in, Lui_in, Bne_in, Beq_in, Blez_in, Bgtz_in, Bz_in, HI_LO_Write_enable_in,
        Jmp_in, Jr_in, Memwrite_in, Memread_in, Byte_in, Signext2_in, Jal_in, Reg_Write_enable_in, Syscall_in,
        HI_Write_to_GPR_in, LO_Write_to_GPR_in;
    input [31:0]Order_in, RD1_in, RD2_in, imm_in, PC_plus_4_in;
    input [4:0]Write_Reg_num_in;
    input [3:0]ALU_OP_in;
    input [1:0]Sel_A_in, Sel_B_in, Mode_in;
    output reg Shift_out, Lui_out, Bne_out, Beq_out, Blez_out, Bgtz_out, Bz_out, Syscall_out, HI_LO_Write_enable_out,
            Jmp_out, Jr_out, Memwrite_out, Memread_out, Byte_out, Signext2_out, Jal_out, Reg_Write_enable_out, HI_Write_to_GPR_out, LO_Write_to_GPR_out;
    output reg [31:0]Order_out, RD1_out, RD2_out, imm_out, PC_plus_4_out;
    output reg [4:0]Write_Reg_num_out;
    output reg [3:0]ALU_OP_out;
    output reg [1:0]Sel_A_out, Sel_B_out, Mode_out;

    initial begin
        Order_out<=0; RD1_out<=0; RD2_out<=0; Shift_out<=0; Lui_out<=0; Bne_out<=0; Beq_out<=0; Blez_out<=0; 
        Bgtz_out<=0; Bz_out<=0; Jmp_out<=0; Jr_out<=0; ALU_OP_out<=0; Sel_A_out<=0; Sel_B_out<=0; 
        PC_plus_4_out<=0; imm_out<=0; Mode_out<=0; Memwrite_out<=0; Memread_out<=0; Byte_out<=0; 
        Signext2_out<=0; Jal_out<=0; Write_Reg_num_out<=0; Reg_Write_enable_out<=0; Syscall_out<=0;
        HI_LO_Write_enable_out<=0;  HI_Write_to_GPR_out<=0;     LO_Write_to_GPR_out<=0;
    end

    always @(posedge clk) begin
        if(rst) begin   
            Order_out<=0; RD1_out<=0; RD2_out<=0; Shift_out<=0; Lui_out<=0; Bne_out<=0; Beq_out<=0; Blez_out<=0; 
            Bgtz_out<=0; Bz_out<=0; Jmp_out<=0; Jr_out<=0; ALU_OP_out<=0; Sel_A_out<=0; Sel_B_out<=0; 
            PC_plus_4_out<=0; imm_out<=0; Mode_out<=0; Memwrite_out<=0; Memread_out<=0; Byte_out<=0; 
            Signext2_out<=0; Jal_out<=0; Write_Reg_num_out<=0; Reg_Write_enable_out<=0; Syscall_out<=0;
            HI_LO_Write_enable_out<=0;  HI_Write_to_GPR_out<=0;     LO_Write_to_GPR_out<=0;
        end
        else if(enable) begin
            Order_out<=Order_in; RD1_out<=RD1_in; RD2_out<=RD2_in; Shift_out<=Shift_in; Lui_out<=Lui_in; 
            Bne_out<=Bne_in; Beq_out<=Beq_in; Blez_out<=Blez_in; 
            Bgtz_out<=Bgtz_in; Bz_out<=Bz_in; Jmp_out<=Jmp_in; Jr_out<=Jr_in; ALU_OP_out<=ALU_OP_in; 
            Sel_A_out<=Sel_A_in; Sel_B_out<=Sel_B_in; 
            PC_plus_4_out<=PC_plus_4_in; imm_out<=imm_in; Mode_out<=Mode_in; Memwrite_out<=Memwrite_in; 
            Memread_out<=Memread_in; Byte_out<=Byte_in; 
            Signext2_out<=Signext2_in; Jal_out<=Jal_in; Write_Reg_num_out<=Write_Reg_num_in; 
            Reg_Write_enable_out<=Reg_Write_enable_in;  Syscall_out<=Syscall_in;
            HI_LO_Write_enable_out<=HI_LO_Write_enable_in;  HI_Write_to_GPR_out<=HI_Write_to_GPR_in;     LO_Write_to_GPR_out<=LO_Write_to_GPR_in;
        end
    end
    
endmodule

`timescale 1ns / 1ps

module EX_MEM(
	input [3:0]ALU_OP_in,
    input Memtoreg_in, Memwrite_in, Alu_src_in, Regwrite_in, Syscall_in, Signedext_in, Regdst_in, Beq_in, Bne_in, 
    input Jr_in, Jmp_in, Jal_in, Shift_in, Lui_in, Blez_in, Bgtz_in, Bz_in, 
    input [1:0]Mode_in,
    input Byte_in, Signext2_in, R1_used_in, R2_used_in,//���Ͼ�Ϊ�����ź�
    input [31:0]Order_in, PC_plus_4_in,
	//�����ǿ����ź�����
	input [31:0] ALU_Result1_in,ALU_Result2_in,
	input ALU_OF_in,ALU_UOF_in,ALU_Equal_in,
	//������ALU�������
	input [31:0] RD2_in,
	input [4:0] Write_Reg_in,
	//����ΪRD2_in,Write_Reg_in
	input clk,clr,Enable_in,
	//����Ϊʱ�ӡ�ͬ�������ʹ��	
	
	output reg [3:0]ALU_OP_out,
    output reg Memtoreg_out, Memwrite_out, Alu_src_out, Regwrite_out, Syscall_out, Signedext_out, Regdst_out, Beq_out, Bne_out, 
    output reg Jr_out, Jmp_out, Jal_out, Shift_out, Lui_out, Blez_out, Bgtz_out, Bz_out, 
    output reg [1:0]Mode_out,
    output reg Byte_out, Signext2_out, R1_used_out, R2_used_out,
    output reg [31:0]Order_out, PC_plus_4_out,
	
	output reg [31:0] ALU_Result1_out,ALU_Result2_out,
	output reg ALU_OF_out,ALU_UOF_out,ALU_Equal_out,
	//������ALU������
	output reg [31:0] RD2_out,
	output reg [4:0] Write_Reg_out,
	//����ΪRD2_out,Write_Reg_out
	output reg Enable_out
	///����ΪEnable_out,������Ϊ������ˮ�ӿڵ� Enable_in ����
);
	initial begin
		ALU_OP_out = 0;
		Memtoreg_out = 0; Memwrite_out = 0; Alu_src_out = 0; Regwrite_out = 0; Syscall_out = 0; Signedext_out = 0; Regdst_out = 0; Beq_out = 0; Bne_out = 0; 
		Jr_out = 0; Jmp_out = 0; Jal_out = 0; Shift_out = 0; Lui_out = 0; Blez_out = 0; Bgtz_out = 0; Bz_out = 0; 
		Mode_out = 0;
		Order_out = 0; PC_plus_4_out = 0;
		ALU_Result1_out = 0;ALU_Result2_out = 0;
		ALU_OF_out = 0;ALU_UOF_out = 0;ALU_Equal_out = 0;
		RD2_out = 0;
		Write_Reg_out = 0;
		Enable_out = 0;
	end
	
	always@(posedge clk) begin
		if(clr == 1)begin
		//�����ź����ȼ����
			ALU_OP_out = 0;
			Memtoreg_out = 0; Memwrite_out = 0; Alu_src_out = 0; Regwrite_out = 0; Syscall_out = 0; Signedext_out = 0; Regdst_out = 0; Beq_out = 0; Bne_out = 0; 
			Jr_out = 0; Jmp_out = 0; Jal_out = 0; Shift_out = 0; Lui_out = 0; Blez_out = 0; Bgtz_out = 0; Bz_out = 0; 
			Mode_out = 0;
			Order_out = 0; PC_plus_4_out = 0;
			ALU_Result1_out = 0;ALU_Result2_out = 0;
			ALU_OF_out = 0;ALU_UOF_out = 0;ALU_Equal_out = 0;
			RD2_out = 0;
			Write_Reg_out = 0;
			Enable_out = 0;
		end
		else if(Enable_in == 1) begin
		//ʹ�ܶ˸ߵ�ƽʱ������ֵ
			ALU_OP_out = ALU_OP_in;
			Memtoreg_out = Memtoreg_in;
			Memwrite_out = Memwrite_in;
			Alu_src_out = Alu_src_in;
			Regwrite_out = Regwrite_in;
			Syscall_out = Syscall_in;
			Signedext_out = Signedext_in;
			Regdst_out = Regdst_in;
			Beq_out = Beq_in;
			Bne_out = Bne_in; 
			Jr_out = Jr_in;
			Jmp_out = Jmp_in;
			Jal_out = Jal_in;
			Shift_out = Shift_in;
			Lui_out = Lui_in;
			Blez_out = Blez_in;
			Bgtz_out = Bgtz_in;
			Bz_out = Bz_in; 
			Mode_out = Mode_in;
			Order_out = Order_in;
			PC_plus_4_out = PC_plus_4_in;
			ALU_Result1_out = ALU_Result1_in;
			ALU_Result2_out = ALU_Result2_in;
			ALU_OF_out = ALU_OF_in;
			ALU_UOF_out = ALU_UOF_in;
			ALU_Equal_out = ALU_Equal_in;
			RD2_out = RD2_in;
			Write_Reg_out = Write_Reg_in;
			Enable_out = Enable_in;
			Byte_out = Byte_in;
			Signext2_out = Signedext_in; 
			R1_used_out = R1_used_in;
			R2_used_out = R2_used_in;

		end
		else begin
		//do nothing
		end
	end
	
endmodule
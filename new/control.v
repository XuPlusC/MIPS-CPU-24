`timescale 1ns / 1ps

module control(
    input [5:0] OP,
    input [5:0]FUNC,
    output reg  [3:0]ALU_OP,
    output reg  Memtoreg, Memwrite, Alu_src, Regwrite, Syscall, Signedext, Regdst, Beq, Bne, Jr, Jmp, Jal, Shift, Lui, Blez, Bgtz, Bz,
    output reg[1:0]Mode
    );
    reg SLL, SRA, SRL, ADD, ADDU, SUB, AND, OR, NOR, SLT, SLTU, JR, SYSCALL, J, JAL, BEQ, BNE, ADDI, ANDI, ADDIU, SLTI, ORI, LW, SW, SLLV, SRLV, SRAV, SUBU, XOR, XORI, LUI, SLTIU, LB, LH, LBU, LHU, SB, SH, BLEZ, BGTZ, BLTZ, BGEZ;
    reg R_type;
    initial begin
		SLL = 0; SRA = 0; SRL = 0; ADD = 0; ADDU = 0; SUB = 0; AND = 0; OR = 0; NOR = 0; SLT = 0; SLTU = 0; JR = 0; SYSCALL = 0; J = 0; JAL = 0; BEQ = 0; BNE = 0; ADDI = 0; ANDI = 0; ADDIU = 0; SLTI = 0; ORI = 0; LW = 0; SW = 0; SLLV = 0; SRLV = 0; SRAV = 0; SUBU = 0; XOR = 0; XORI = 0; LUI = 0; SLTIU = 0; LB = 0; LH = 0; LBU = 0; LHU = 0; SB = 0; SH = 0; BLEZ = 0; BGTZ = 0; BLTZ = 0; BGEZ = 0;
	end
	
	always @(OP or FUNC) begin
		J = (OP == 2)?1:0;
		JAL = (OP == 3)?1:0;
		BEQ = (OP == 4)?1:0;
		BNE = (OP == 5)?1:0;
		BLEZ = (OP == 6)?1:0;
		BGTZ = (OP == 7)?1:0;
		ADDI = (OP == 8)?1:0;
		ADDIU = (OP == 9)?1:0;
		SLTI = (OP == 10)?1:0;
		SLTIU = (OP == 11)?1:0;
		ANDI = (OP == 12)?1:0;
		ORI = (OP == 13)?1:0;
		XORI = (OP == 14)?1:0;
		LUI = (OP == 15)?1:0;
		LB = (OP == 32)?1:0;
		LH = (OP == 33)?1:0;
		LW = (OP == 35)?1:0;
		LBU = (OP == 36)?1:0;
		LHU = (OP == 37)?1:0;
		SB = (OP == 40)?1:0;
		SH = (OP == 41)?1:0;
		SW = (OP == 43)?1:0;
		
		if(OP!=0)begin
			SLL = 0;SRA = 0;SRL = 0;ADD = 0;ADDU = 0;SUB = 0;AND = 0;OR = 0;NOR = 0;SLT = 0;SLTU = 0;JR = 0;SYSCALL = 0;SLLV = 0;SRLV = 0;SRAV = 0;SUBU = 0;XOR = 0;		
		end		
		else begin
		SLL = (FUNC == 0)?1:0;
		SRL = (FUNC == 2)?1:0;
		SRA = (FUNC == 3)?1:0;
		SLLV = (FUNC == 4)?1:0;
		SRLV = (FUNC == 6)?1:0;
		SRAV = (FUNC == 7)?1:0;
		JR = (FUNC == 8)?1:0;
		SYSCALL = (FUNC == 12)?1:0;
		ADD = (FUNC == 32)?1:0;
		SUB = (FUNC == 34)?1:0;
		SUBU = (FUNC == 35)?1:0;
		ADDU = (FUNC == 33)?1:0;
		AND = (FUNC == 36)?1:0;
		OR = (FUNC == 37)?1:0;
		XOR = (FUNC == 38)?1:0;
		NOR = (FUNC == 39)?1:0;
		SLT = (FUNC == 42)?1:0;
		SLTU = (FUNC == 43)?1:0;
		end
        if (OP == 0 && SYSCALL == 0)begin
            R_type = 1;
        end
        else R_type = 0;

        ALU_OP = (ADD || ADDU || ADDI || ADDIU || LW || SW || LB || LH || LBU || LHU || SB || SH) ? 5 :
                (SLL || SLLV || LUI) ? 0 :
                (SRA || SRAV) ? 1 :
                (SRL || SRLV) ? 2 :
                (SUB || SUBU) ? 6 :
                (AND || ANDI) ? 7 :
                (OR || ORI) ? 8 :
                (XOR || XORI) ? 9 :
                (SLT || SLTI) ? 11 :
                (SLTU || SLTIU) ? 12 : 
                NOR ? 10 : 0;
        Memtoreg = LW || LB || LH || LBU || LHU;
        Memwrite = SW || SB || SH;
        Alu_src = ADDI || ANDI || ADDIU || SLTI || ORI || LW || SW || XORI || LUI || SLTIU || LB || LH || LBU || LHU || SB || SH;
        Regwrite = R_type || JAL || ADDI || ANDI || ADDIU || SLTI || ORI || LW || XORI || LUI || SLTIU || LB || LH || LBU || LHU;
        Syscall = SYSCALL;
        Signedext = ADDI || ADDIU || SLTI || LW || SW || LB || LH || LBU || LHU || SB || SH;
        Regdst = R_type;
        Beq = BEQ;
        Bne = BNE;
        Jr = JR;
        Jmp = JAL || Jr || J;
        Jal = JAL;
        Shift = SLLV || SRLV || SRAV;
        Lui = LUI;
        Blez = BLEZ;
        Bgtz = BGTZ;
        Bz = (OP == 1)? 1 : 0;
        Mode = (LB || LBU || SB)? 2'b00 :
                (LH || LHU || SH)? 2'b01 : 2'b10;
	end
endmodule

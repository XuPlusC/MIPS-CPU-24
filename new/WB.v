`timescale 1ns / 1ps

module WB(clk, rst, Order, RegFile_Din, Write_Reg_num, Reg_Write_enable, HI_LO_Write_enable, HI_in, 
		HI_Write_to_GPR, LO_Write_to_GPR, IR0, IR1, IR2, IR3, Circular_ERET_In, WB_NOINT_NextPC, WB_INT_PC_Choose, PC_plus_4,
        Circular_IE_Close_in, // Input Signals
        RegFile_Din_out, Int_NextPC, IntRequest, IntWaiting0, IntWaiting1, IntWaiting2, IntWaiting3, Circular_ERET_Out, EPC_out,
        Circular_IE_Close_out);
    input [31:0]RegFile_Din, Order, HI_in, WB_NOINT_NextPC, PC_plus_4;
    input [4:0]Write_Reg_num;
    input clk, rst, Reg_Write_enable, HI_LO_Write_enable, HI_Write_to_GPR, LO_Write_to_GPR, IR0, IR1, IR2, IR3, WB_INT_PC_Choose;
    input Circular_ERET_In, Circular_IE_Close_in;
    output [31:0]RegFile_Din_out;
    //////////////
    output [31:0] Int_NextPC, EPC_out;
    output IntRequest, IntWaiting0, IntWaiting1, IntWaiting2, IntWaiting3;
    output Circular_ERET_Out, Circular_IE_Close_out;
    /////////////
    
    wire [31:0]HI_out, LO_out;
    Register_HI_LO hi_lo(clk, rst, HI_LO_Write_enable, HI_in, RegFile_Din, HI_out, LO_out);

    parameter WIDTH = 32;
    wire [4:0] CP0_R_in, CP0_W_in;
	wire CP0_WE, CP0_clr; //CP0_EPC_WE, 
	wire [2:0]CP0_Sel;
	wire [WIDTH-1:0] CP0_R_out;// CP0_EPC_out;

	assign CP0_WE = ((Order[31:26] == 6'b010000)&(Order[25:21] == 5'b00100))?1:0;
	//assign CP0_EPC_WE = CP0_WE & Order[15:11] == 5'b01110;
	assign CP0_Sel = Order[2:0];
	assign CP0_R_in = Order[15:11];
	assign CP0_W_in = CP0_R_in;

	wire CP0_Write_to_GPR, CP0_EPC_Write_to_GPR;
	assign CP0_Write_to_GPR = (Order[31:26] == 6'b010000)&(Order[25:21] == 5'b00000);
	assign CP0_EPC_Write_to_GPR = (CP0_Write_to_GPR)&(Order[15:11] == 5'b01110);
	wire [31:0]CP0_Out, EPC_in; 	// EPC_in is for current-stage protection, when posedge IntRequest, EPC was set to EPC_in
    wire NMI_zero, NMI_out, IE;

    assign EPC_in = (IntRequest == 1)? 
    					(
    						(WB_INT_PC_Choose == 1)?WB_NOINT_NextPC:PC_plus_4
						):0;
    wire IntExist;
    assign IntExist = IntWaiting0 | IntWaiting1 | IntWaiting2 | IntWaiting3;
	CP0 CP01 (.R_in(CP0_R_in), .W_in(CP0_W_in), .Din(RegFile_Din), .WE(CP0_WE), .sel(CP0_Sel), .clk(clk), .clr(rst), 
				 .NMI_one(1'b0), .NMI_zero(NMI_zero), .IE_one(Circular_ERET_In), .IntRequest(IntRequest), .EPC_in(EPC_in), // input signals
				 .IE_zero(Circular_IE_Close_in), .NMI_out(NMI_out), .IE_out(IE), .R_out(CP0_Out), .EPC_out(EPC_out));
	// TEMP!!!!!!!!!!!!!
	// assign IE_zero = 0;
	assign NMI_zero = 0;


	// TODO the following rst is not sure
    // CP0 cp0(CP0_R_in, CP0_W_in, RegFile_Din, RegFile_Din, CP0_WE, CP0_EPC_WE, CP0_Sel, clk, rst, CP0_Out, CP0_EPC_out);
    assign RegFile_Din_out = HI_Write_to_GPR ? HI_out : 
    		(
    			LO_Write_to_GPR ? LO_out : 
    			(
    				CP0_Write_to_GPR ? 
    				(
    					//CP0_EPC_Write_to_GPR ? CP0_EPC_out : CP0_Out
						CP0_Out
					)
    				:
    				RegFile_Din
				)
			);

    wire ERET;
    wire [1:0]Int_Num;
    assign ERET = (Order == 32'b0100_0010_0000_0000_0000_0000_0001_1000);
	InterruptControl INTControl (clk, IR0, IR1, IR2, IR3, 0, 0, 0, 0, ERET, IE, Circular_ERET_In, WB_NOINT_NextPC, 
									Int_Num, IntRequest, IntWaiting0, IntWaiting1, IntWaiting2, IntWaiting3);

	Mux_2 #(.WIDTH(32)) IntPCMux (1400, 1600, 750, 950, Int_Num, Int_NextPC);

	assign Circular_ERET_Out = ERET;
    assign Circular_IE_Close_out = IntRequest;
endmodule

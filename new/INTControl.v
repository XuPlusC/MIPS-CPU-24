module PriorityEncoder(input3,input2,input1,input0,priority_code);
	input input3,input2,input1,input0;
	//四个输入，其中input3优先级最高
	output reg [1:0] priority_code;

	initial begin
		priority_code = 0;
	end

	always @(*) begin
		if(input3)begin
			priority_code = 3;
		end
		else if(input2)begin
			priority_code = 2;
		end
		else if(input1) begin
			priority_code = 1;
		end
		else begin
			priority_code = 0;
		end
	end
endmodule

module BlockDecoder(signal_in,clr,clk,INTExsist,signal_0_out,signal_1_out,signal_2_out,signal_3_out);
	input clr, clk, INTExsist;
	//clr:all output turns to 1'b1
	input [1:0] signal_in;
	output reg signal_0_out,signal_1_out,signal_2_out,signal_3_out;

	initial begin
		signal_0_out = 1;
		signal_1_out = 1;
		signal_2_out = 1;
		signal_3_out = 1;
	end

	always @(posedge clk) begin
		if(clr == 1) begin
			signal_3_out = 1;
		end
		else if(signal_in == 3) begin
			signal_3_out = 0;
		end
		else begin
			signal_3_out = 1;
		end
	end

	always @(posedge clk) begin
		if(clr == 1) begin
			signal_2_out = 1;
		end
		else if(signal_in == 2 || signal_in == 3) begin
			signal_2_out = 0;
		end
		else begin
			signal_2_out = 1;
		end
	end

	always @(posedge clk) begin
		if(clr == 1) begin
			signal_1_out = 1;
		end
		else if(signal_in == 1 ||signal_in == 2 || signal_in == 3) begin
			signal_1_out = 0;
		end
		else begin
			signal_1_out = 1;
		end
	end

	always @(posedge clk) begin
		if(clr == 1) begin
			signal_0_out = 1;
		end
		else if(signal_in == 1 ||signal_in == 2 ||signal_in == 3 || (signal_in == 0 & INTExsist)) begin
			signal_0_out = 0;
		end
		else begin
			signal_0_out = 1;
		end
	end

endmodule


module InterruptSampling(clk, clr, IntSignal, Waiting, IntRequest);
	input clk, clr, IntSignal;
	output Waiting, IntRequest;
	wire DFF_1_clr, DFF_1_Q, IR_Din, IR_Q;

	assign IR_Din = (DFF_1_Q | IR_Q) & ~clr;
	assign Waiting = IR_Q | DFF_1_Q;
	assign IntRequest = IR_Q;
	assign DFF_1_clr = IR_Q;

	D_Flip_Flop DFF_1(IntSignal, DFF_1_clr, 1, DFF_1_Q);
	D_Flip_Flop IR(clk, 0, IR_Din, IR_Q);
endmodule

module D_Flip_Flop(clk, clr, Din, Q);
	input clk, clr, Din;
	output reg Q;

	initial begin
		Q = 0;
	end

	always @(posedge clk or posedge clr) begin
		if (clr) begin
			// reset
			Q = 0;
		end
		else begin
			Q = Din;
		end
	end
endmodule

module InterruptSheild(clk, IR0, IR1, IR2, IR3, INM0, INM1, INM2, INM3, IntEnable, Circular_ERET_In, IntNum, IntRequest);
	input clk, IR0, IR1, IR2, IR3, INM0, INM1, INM2, INM3, IntEnable, Circular_ERET_In;
	output [1:0]IntNum;
	output IntRequest;

	wire I0, I1, I2, I3, INTExsist, Block0, Block1, Block2, Block3;

	assign I0 = IR0 & ~INM0;
	assign I1 = IR1 & ~INM1;
	assign I2 = IR2 & ~INM2;
	assign I3 = IR3 & ~INM3;
	assign INTExsist = I0 | I1 | I2 | I3;
	PriorityEncoder PriEncoder(I3, I2, I1, I0, {IntNum[1], IntNum[0]});

	BlockDecoder Block(.signal_in(IntNum), .clr(Circular_ERET_In), .clk(clk), .INTExsist(INTExsist),
						.signal_0_out(Block0), .signal_1_out(Block1), .signal_2_out(Block2), .signal_3_out(Block3));

	wire INTChange;
	assign INTChange = (I0 & Block0) | (I1 & Block1) | (I2 & Block2) | (I3 & Block3);
	assign IntRequest = IntEnable & INTChange;
endmodule

module InterruptControl (clk, IntSignal0, IntSignal1, IntSignal2, IntSignal3, INM0, INM1, INM2, INM3, ERET, IntEnable, Circular_ERET_In, WB_NOINT_NextPC, 
							IntNum, IntRequest, IntWaiting0, IntWaiting1, IntWaiting2, IntWaiting3);
	input clk, IntSignal0, IntSignal1, IntSignal2, IntSignal3, INM0, INM1, INM2, INM3, ERET, IntEnable, Circular_ERET_In;
	input [31:0]WB_NOINT_NextPC;
	output [1:0]IntNum;
	output IntRequest, IntWaiting0, IntWaiting1, IntWaiting2, IntWaiting3;
	wire IR0, IR1, IR2, IR3, IntEnd0, IntEnd1, IntEnd2, IntEnd3;

	assign  IntEnd0 = ERET & (IntNum == 0);
	assign  IntEnd1 = ERET & (IntNum == 1);
	assign  IntEnd2 = ERET & (IntNum == 2);
	assign  IntEnd3 = ERET & (IntNum == 3);

	InterruptSampling IntSamp0(clk, IntEnd0, IntSignal0, IntWaiting0, IR0);
	InterruptSampling IntSamp1(clk, IntEnd1, IntSignal1, IntWaiting1, IR1);
	InterruptSampling IntSamp2(clk, IntEnd2, IntSignal2, IntWaiting2, IR2);
	InterruptSampling IntSamp3(clk, IntEnd3, IntSignal3, IntWaiting3, IR3);

	InterruptSheild IntSheild(clk, IR0, IR1, IR2, IR3, INM0, INM1, INM2, INM3, IntEnable, Circular_ERET_In, IntNum, IntRequest);

	// IR0, IR1, IR2, IR3, INM0, INM1, INM2, INM3, IntEnable, IntNum, IntRequest	
endmodule
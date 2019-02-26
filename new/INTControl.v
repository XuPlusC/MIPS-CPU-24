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

module InterruptSheild(IR0, IR1, IR2, IR3, INM0, INM1, INM2, INM3, IntEnable, IntNum, IntRequest);
	input IR0, IR1, IR2, IR3, INM0, INM1, INM2, INM3, IntEnable;
	output [1:0]IntNum;
	output IntRequest;

	wire I0, I1, I2, I3, IR;

	assign I0 = IR0 & ~INM0;
	assign I1 = IR1 & ~INM1;
	assign I2 = IR2 & ~INM2;
	assign I3 = IR3 & ~INM3;
	assign IR = I0 | I1 | I2 | I3;
	assign IntRequest = IntEnable & IR;
	PriorityEncoder PriEncoder(I3, I2, I1, I0, {IntNum[1], IntNum[0]});
endmodule

module InterruptControl (clk, IntSignal0, IntSignal1, IntSignal2, IntSignal3, INM0, INM1, INM2, INM3, ERET, IntEnable, 
							IntNum, IntRequest, IntWaiting0, IntWaiting1, IntWaiting2, IntWaiting3);
	input clk, IntSignal0, IntSignal1, IntSignal2, IntSignal3, INM0, INM1, INM2, INM3, ERET, IntEnable;
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

	InterruptSheild IntSheild(IR0, IR1, IR2, IR3, INM0, INM1, INM2, INM3, IntEnable, IntNum, IntRequest);

	// IR0, IR1, IR2, IR3, INM0, INM1, INM2, INM3, IntEnable, IntNum, IntRequest	
endmodule
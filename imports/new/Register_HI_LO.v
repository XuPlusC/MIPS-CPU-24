`timescale 1ns / 1ps

module Register_HI_LO(clk, rst, WE, HI_in, LO_in, HI_Reg, LO_Reg);
	parameter WIDTH = 32;
	input clk, rst;
	//ʱ�ӣ�����Ρ�����θߵ�ƽ��Ч�����ȼ���ߡ�
	input WE;
	//HI,LO��дʹ���źš��ߵ�ƽ��Ч��
	input [WIDTH-1:0] HI_in, LO_in;
	//��Ҫд��HI,LO��ֵ
	output reg [WIDTH-1:0] HI_Reg, LO_Reg;
	//HI,LO�е�ֵ
	
	initial begin
		HI_Reg <= 0;   LO_Reg <= 0;
	end
	
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			HI_Reg <= 0;   LO_Reg <= 0;
		end
		else begin
			if(WE) begin  HI_Reg <= HI_in;   LO_Reg <= LO_in; end
		end
	end
endmodule

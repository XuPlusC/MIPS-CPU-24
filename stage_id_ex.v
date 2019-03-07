/*
**  作者：马翔
**  功能：ID-EX流水接口
**  原创
*/

`define CONTROL_BUS_WIDTH 35

module ID_EX(
	input 								clk,
	input								rset,
	
	input								stall,
    input 		[`CONTROL_BUS_WIDTH:0]	control_signal_in,
    input 		[4:0]					register1_in,
    input 		[4:0]					register2_in,
    input 		[4:0]					registerW_in,
    input 		[31:0]					value_A_in,
    input 		[31:0]					value_B_in,
    input 		[31:0]					value_Imm_in,
    input 		[31:0]					PC_in,
    input 		[2:0]					sel_in,
    input 		[63:0]					HILO_in,
    input 		[31:0]					cp0_data_in,
    input 		[4:0]					cp0_rw_reg_in,
    input 								illegal_pc_in,
    input 								in_delayslot_in,
	input 		[4:0]					lsb_in,

    output reg 	[`CONTROL_BUS_WIDTH:0]	control_signal_out,
    output reg 	[4:0]					register1_out,
    output reg 	[4:0]					register2_out,
    output reg 	[4:0]					registerW_out,
    output reg 	[31:0]					value_A_out,
    output reg 	[31:0]					value_B_out,
    output reg 	[31:0]					value_Imm_out,
    output reg 	[31:0]					PC_out,
    output reg 	[2:0]					sel_out,
    output reg 	[63:0]					HILO_out,
    output reg 	[31:0]					cp0_data_out,
    output reg 	[4:0]					cp0_rw_reg_out,
    output reg 							illegal_pc_out,
    output reg 							in_delayslot_out,
	output reg  [4:0]					lsb_out
);
    
    always@(posedge clk)begin
		if (!rset) begin
			control_signal_out 	<= 'd0;
			register1_out 		<= 'd0;
			register2_out 		<= 'd0;
			registerW_out 		<= 'd0;
			value_A_out 		<= 'd0;
			value_B_out 		<= 'd0;
			value_Imm_out 		<= 'd0;
			PC_out 				<= 'd0;
			sel_out 			<= 'd0;
			HILO_out 			<= 'd0;
			cp0_data_out 		<= 'd0;
			cp0_rw_reg_out 		<= 'd0;
			illegal_pc_out 		<= 1'b0;
			in_delayslot_out 	<= 1'b0;
			lsb_out				<= 5'b0;
		end
		else if (!stall) begin
			control_signal_out 	<= control_signal_out;
			register1_out 		<= register1_out;
			register2_out 		<= register2_out;
			registerW_out 		<= registerW_out;
			value_A_out 		<= value_A_out;
			value_B_out 		<= value_B_out;
			value_Imm_out 		<= value_Imm_out;
			PC_out 				<= PC_out; 
			sel_out 			<= sel_out;  
			HILO_out 			<= HILO_out;
			cp0_data_out 		<= cp0_data_out;
			cp0_rw_reg_out 		<= cp0_rw_reg_out;
			illegal_pc_out 		<= illegal_pc_out;
			in_delayslot_out 	<= in_delayslot_out;
			lsb_out				<= lsb_out;
		end
		else begin
			control_signal_out 	<= control_signal_in;
			register1_out 		<= register1_in;
			register2_out 		<= register2_in;
			registerW_out 		<= registerW_in;
			value_A_out 		<= value_A_in;
			value_B_out 		<= value_B_in;
			value_Imm_out 		<= value_Imm_in;
			PC_out 				<= PC_in;  
			sel_out 			<= sel_in;
			HILO_out 			<= HILO_in;
			cp0_data_out 		<= cp0_data_in;
			cp0_rw_reg_out 		<= cp0_rw_reg_in;
			illegal_pc_out 		<= illegal_pc_in;
			in_delayslot_out 	<= in_delayslot_in;
			lsb_out				<= lsb_in;
		end 
    end
	
endmodule

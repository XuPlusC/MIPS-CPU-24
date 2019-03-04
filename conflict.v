/*
**	作者：张鑫
**	功能：load-use冲突检测，生成气泡信号
**	原创
*/
module conflict(
	input 			r1_r_id,	//读通用寄存器的第1路
	input 			r2_r_id,	//读通用寄存器的第2路
	input [4:0]		r1_id,		//读通用寄存器1的编号
	input [4:0]		r2_id,		//读通用寄存器2的编号
	input [4:0]		rw_ex,		//执行段写寄存器编号
	input [4:0]		rw_mem,		//访存段写寄存器编号
	input 			load_ex,	//lh、lb、lw等指令
	input 			load_mem,
	
	output conflict_stall		//气泡
);
	
	wire and1;
	wire and2;
	wire and3;
	wire and4;

	assign and1 = r1_r_id && (r1_id==rw_ex);
	assign and2 = r2_r_id && (r2_id==rw_ex);
	assign and3 = r1_r_id && (r1_id==rw_mem);
	assign and4 = r2_r_id && (r2_id==rw_mem);

	assign conflict_stall = ( load_ex && (and1 || and2) && (rw_ex!=0) )
						  ||( load_mem && (and3 ||and4) && (rw_mem!=0) );
endmodule

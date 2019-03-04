/*
**  作者：林力韬
**  功能：异常处理
**  参考清华大学设计，修改了部分接口
*/
module exception(
	input 							invalid_inst,		//控制器判断的未定义指令
	input 							syscall,			//系统调用
	input 							break_inst,			//break指令
	input 							eret,				//中断返回指令
	input 		[31:0]				pc_value,			//PC现值
	input 							in_delayslot,		//在分支延迟槽发生异常的标记信号，由控制器判断
	input 							overflow,			//整数运算溢出
	input 		[7:0]				interrupt_flags,	//中断信号，包括软硬中断
	input 							allow_int,			//中断使能,{SR(ERL,EXL,IE)==001}
	input		[19:0] 				ebase_in,			//(15.1)EBase,产生exception_base
	input		[31:0] 				epc_in,				//(14)EPC
	input 							special_int_vec,	//(13)Cause(VI)[23],使用特殊中断入口
	input 							boot_exp_vec,		//在启动初始化状态下异常的处理信号
	input 							iaddr_exp_illegal,	//指令地址错异常信号
	input 							daddr_exp_illegal,	//数据地址错异常信号
	input 		[31:0] 				mem_data_vaddr,		//数据地址错时访问的地址
	input 							mem_data_we,		//数据地址错时对访问地址的读写控制信号
	
	output reg 						flush,				//异常时清空流水前段的信号
	output reg 						cp0_wr_exp,			//送CP0异常信号，一般用于相关寄存器的写入控制
	output reg 						cp0_clean_exl,		//清除SR[EXL]的信号
	output reg	[31:0] 				exp_epc,			//异常后应记录的EPC
	output reg	[4:0] 				exp_code,			//异常的编号
	output reg	[31:0] 				exception_new_pc,	//异常后的新PC	
	output reg	[31:0] 				exp_bad_vaddr,		//发生异常的地址(8)BadVaddr
	output reg 						cp0_badv_we,		//异常地址写入控制信号
	output reg	[7:0] 				exp_asid,			//发生异常时的线程号，ENTRYHi(ASID)
	output reg 						cp0_exp_asid_we		//写入异常线程号的使能信号
);


	wire[31:0] exception_base;
	assign exception_base = boot_exp_vec ? 32'hBFC00200 : {ebase_in, 12'b0};//启动状态和一般状态下异常处理基址不同

	always @(*) begin
		//注意：以下部分相当于顺序执行，某个值先后多次赋值的话，后值会覆盖前值
		//初始化输出的值
		cp0_wr_exp <= 1'b1;		//向CP0报告例外或中断发生,需要修改EXL位
		cp0_clean_exl <= 1'b0;	//屏蔽其他的中断和例外，陷入内核
		flush <= 1'b1;			//如果是可识别的情形，给出高电平流水清空信号，否则保持低电平
	
		exp_bad_vaddr <= 32'b0;	//默认是不登记bad_vaddr和asid的
		cp0_badv_we <= 1'b0;
	
		exp_asid <= 8'b0;
		cp0_exp_asid_we <= 1'b0;
	
		exp_epc <= in_delayslot ? (pc_value-32'd4) : pc_value;//将PC移入EPC，若是延迟槽异常回退一条到分支
		exception_new_pc <= exception_base + 32'h180;//异常后的PC先指向其他异常,初始默认是32'h(BFC00200+180)
	
		if((~invalid_inst) && allow_int && (interrupt_flags!=8'h0)) begin//使能，且存在中断信号
			if(special_int_vec)
				exception_new_pc <= exception_base + 32'h200;//Cause(IV)为1表示使用特殊中断入口
			exp_code <= 5'h00;//发生Int中断，异常代号为0
		end
		//指令地址错
		else if(iaddr_exp_illegal) begin//指令出错，记录出错地址，异常代号为4表示从地址加载指令出错
			exp_bad_vaddr <= pc_value;
			cp0_badv_we <= 1'b1;//记录遇到的错误地址
			exp_code <= 5'h04; //AdEL
		end
		else if(invalid_inst) begin//未定义指令
			exp_code <= 5'h0a;
		end
		else if(overflow) begin//整数运算溢出
			exp_code <= 5'h0c;
		end
		else if(syscall) begin//Syscall
			exp_code <= 5'h08;
		end
		else if(break_inst) begin//Bp
			exp_code <= 5'h09;
		end
		//数据地址错
		else if(daddr_exp_illegal) begin//数据地址出错，记录出错的访存地址，根据写使能报告是读还是写时出错
			exp_bad_vaddr <= mem_data_vaddr;
			cp0_badv_we <= 1'b1;//记录遇到的错误地址
			exp_code <= mem_data_we ? 5'h05 : 5'h04; //AdES : AdEL 读写报告不同的异常代号
		end
		else if(eret) begin    //ERET is not a real exception
			exp_code <= 5'h00;//清除异常编号
			cp0_wr_exp <= 1'b0;//清除异常信号
			cp0_clean_exl <= 1'b1;//异常级别SR[EXL]在这条指令后恢复,离开内核态
			exception_new_pc <= epc_in;//恢复到CP0中保存的EPC位置执行
		end
		else begin
			cp0_wr_exp <= 1'b0;//无法识别的异常予以清除
			flush <= 1'b0;//清除异常的清空流水段信号，继续执行
			exp_code <= 5'h00;//清除无法识别的异常编号
		end
	end
	
endmodule
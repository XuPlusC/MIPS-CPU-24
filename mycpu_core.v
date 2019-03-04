/*
**	作者：张鑫
**	功能：数据通路
**	原创
*/

`define CONTROL_BUS_WIDTH 	33

module mycpu_core(
	// cpu时钟和复位信号
	input wire 				aclk,
    input wire 				aresetn,
	
	// 外部硬件中断输入
	input	[5:0]			interrupt,
	
	// AXI4总线
	// 读地址通道
    output 	[3:0]			arid,
    output 	[31:0]			araddr,
    output 	[7:0]			arlen,
    output 	[2:0]			arsize,
    output 	[1:0]			arburst,
    output 	[1:0]			arlock,
    output 	[3:0]			arcache,
    output 	[2:0]			arprot,
    output 					arvalid,
    input wire 				arready,
	// 读数据通道
    input 	[3:0]			rid,
    input 	[31:0]			rdata,
    input 	[1:0]			rresp,
    input 					rlast,
    input 					rvalid,
    output 					rready,
	// 写地址通道
    output 	[3:0]			awid,
    output 	[31:0]			awaddr,
    output 	[7:0]			awlen,
    output 	[2:0]			awsize,
    output 	[1:0]			awburst,
    output 	[1:0]			awlock,
    output 	[3:0]			awcache,
    output 	[2:0]			awprot,
    output 					awvalid,
    input 					awready,
	// 写数据通道
    output 	[3:0]			wid,
    output 	[31:0]			wdata,
    output 	[3:0]			wstrb,
    output 					wlast,
    output 					wvalid,
    input 					wready,
	// 写响应通道
    input 	[3:0]			bid,
    input 	[1:0]			bresp,
    input 					bvalid,
    output 					bready
	
    //debug interface
    //output 	[31:0]			debug_wb_pc,
    //output 	[3:0]			debug_wb_rf_wen,
    //output 	[4:0]			debug_wb_rf_wnum,
    //output 	[31:0]			debug_wb_rf_wdata
);

	//----global---
	reg 					rst;
	wire 					rst_pc;
	wire 					rst_ifid;
	wire 					rst_idex;
	wire 					rst_exmem;
	wire 					rst_memwb;
	wire 					stall_pc;
	wire 					stall_ifid;
	wire 					stall_idex;
	wire 					stall_exmem;
	wire 					stall_memwb;
	wire 					ins_stall;
    wire 					data_stall;
    wire 					load_use;
    wire 					is_diving;
    wire 					special_pop;

	//-----if stage---
	wire 	[31:0]			pc_if;
	wire 	[31:0]			instruction_if;
	wire 					illegal_pc_if;
	wire 					in_delayslot_if;
	wire 	[31:0]			physical_pc;

	//-----id stage---
	wire 	[31:0]			instruction_id;
	wire 	[31:0]			pc_id;
	wire 	[4:0]			rs_id;
	wire 	[4:0]			rt_id;
	wire 	[4:0]			rd_id;
	wire 	[5:0]			op_id;
	wire 	[5:0]			func_id;
	wire 	[15:0]			imm16_id;
	wire 	[25:0]			imm26_id;
	wire 	[31:0]			imm32_id;
	wire 	[4:0]			shamt_id;
	wire 	[2:0]			sel_id;
	wire 	[`CONTROL_BUS_WIDTH:0]	control_id;
	wire 	[9:0]			bj_num_id;
	wire 	[31:0]			rdata1_id;
	wire 	[31:0]			rdata2_id;
	wire 	[31:0]			real_rdata1_id;
	wire 	[31:0]			real_rdata2_id;
	wire 					is_bj_id;
	wire 	[31:0]			bj_address_id;
	wire 	[1:0]			ext_sel_id;
	wire 					r1_sel_id;
	wire 					r2_sel_id;
	wire 	[4:0]			r1_id;
	wire 	[4:0]			r2_id;
	wire 	[1:0]			rw_sel_id;
	wire 	[4:0]			rw_id;
	wire 	[63:0]			hilo_id;
	wire 	[63:0]			real_hilo_id;
	wire 					r1_r_id;
	wire 					r2_r_id;
	wire 					illegal_pc_id;
	wire 					in_delayslot_id;
	wire 	[31:0]			cp0_data_id;

	//-----ex stage---
	wire 	[`CONTROL_BUS_WIDTH:0]	control_ex;
	wire 	[4:0]			r1_ex;
	wire 	[4:0]			r2_ex;
	wire 	[4:0]			rw_ex;
	wire 	[31:0]			rdata1_ex;
	wire 	[31:0]			rdata2_ex;
	wire 	[31:0]			imm32_ex;
	wire 	[31:0]			pc_ex;
	wire 	[2:0]			sel_ex;
	wire 	[63:0]			hilo_ex;
	wire 	[31:0]			cp0_data_ex;
	wire 	[4:0]			rd_ex;
	wire 	[31:0]			alu_a_ex;
	wire 	[31:0]			alu_b_ex;
	wire 	[3:0]			aluop_ex;
	wire 	[1:0]			add_sub_ex;
	wire 	[31:0]			alu_r1_ex;
	wire 	[31:0]			alu_r2_ex;
	wire 	[31:0]			alu_r1_ex_no_mult_ex;
	wire 	[31:0]			alu_r2_ex_no_mult_ex;
	wire 					overflow_ex;
	wire 	[1:0]			alua_sel_ex;
	wire 	[1:0]			alub_sel_ex;
	wire 					illegal_pc_ex;
	wire 					in_delayslot_ex;
	wire 					load_ex;
	wire 	[2:0]			din_sel_ex;
	wire 	[2:0] 			load_store_ex;
	wire 	[1:0]			hilo_mode_ex;

	//-----mem stage--
	wire 	[`CONTROL_BUS_WIDTH:0]	control_mem;
	wire 	[4:0]			rw_mem;
	wire 	[31:0]			alu_r1_mem;
	wire 	[31:0]			alu_r2_mem;
	wire 	[31:0]			rdata1_mem;
	wire 	[31:0]			rdata2_mem;
	wire 	[31:0]			pc_mem;
	wire 	[2:0]			sel_mem;
	wire 	[63:0]			hilo_mem;
	wire 	[31:0]			cp0_data_mem;
	wire 	[4:0]			rd_mem;
	wire 					overflow_mem;
	wire 	[31:0]			DMout_mem;
	wire 	[3:0]			mode_mem;
	wire 					load_mem;
	wire 	[1:0]			hilo_mode_mem;
	wire 	[2:0]			load_store_mem;
	wire 	[31:0]			dram_wdata_mem;
	wire 					dm_addr_illegal_mem;
	wire 					illegal_pc_mem;
	wire 	[2:0]			din_sel_mem;
	wire 					not_nop_mem;
	wire 	[31:0]			physical_dm_addr;

	//-----wb stage---
	wire 	[`CONTROL_BUS_WIDTH:0]	control_wb;
	wire 	[4:0]			rw_wb;
	wire 	[31:0]			alu_r1_wb;
	wire 	[31:0]			alu_r2_wb;
	wire 	[31:0]			DMout_wb;
	wire 	[31:0]			real_DMout_wb;
	wire 	[31:0]			pc_wb;
	wire 	[2:0]			sel_wb;
	wire 	[63:0]			hilo_wb;
	wire 	[31:0]			cp0_data_wb;
	wire 	[31:0]			rdata1_wb;
	wire 	[31:0]			rdata2_wb;
	wire 	[4:0]			rd_wb;
	wire 	[31:0]			reg_din_wb;
	wire 	[1:0]			hilo_mode_wb;
	wire 	[2:0]			din_sel_wb;
	wire 					reg_we_wb;
	wire 	[2:0]			load_store_wb;
	
	//cp0 exception
	wire 	[19:0]			ebase_id;
	wire 	[31:0]			epc_id;
	wire 					allow_int_id;
	wire 					special_int_vec_id;
	wire 					boot_exp_vec_id;
	wire 	[4:0]			exception_code_mem;
	wire 					cp0_exp_asid_we_mem;
	
	wire 					cp0_we_wb;
	wire 	[5:0]			hardware_int;
	wire 	[1:0]			software_int;
	wire 					cp0_exl_mem;
	wire 					cp0_wr_exp_mem;
	wire 	[31:0]			exp_epc_mem;
	wire 	[31:0]			exp_bad_vaddr_mem;
	wire 	[7:0]			exp_asid_mem;
	wire 					cp0_badv_we_mem;
	wire 					is_exception_mem;
	wire 	[31:0]			exception_new_pc_mem;
	
	wire 					invalid_inst_mem;
	wire 					syscall_mem;
	wire 					break_mem;
	wire 					eret_mem;
	wire 					in_delayslot_mem;
	wire 	[7:0]			interrupt_flags;
	
	// pipeline stall signals
	assign stall_pc    = ~(data_stall | ins_stall | is_diving | special_pop | load_use & (~is_exception_mem) );
	assign stall_ifid  = ~(data_stall | ins_stall | is_diving | special_pop | load_use & (~is_exception_mem) );
	assign stall_idex  = ~(data_stall | ins_stall | is_diving | special_pop);
	assign stall_exmem = ~(data_stall | ins_stall | is_diving);
	assign stall_memwb = ~(data_stall | ins_stall | is_diving);

	// reset signals
	assign rst_pc    = aresetn;
	assign rst_ifid  = aresetn & (rst &  ~is_exception_mem | ~stall_ifid );
	assign rst_idex  = aresetn & (rst &  ~load_use & ~is_exception_mem | ~stall_idex);
	assign rst_exmem = aresetn & (rst & ~special_pop & ~is_exception_mem | ~stall_exmem) ;
	assign rst_memwb = aresetn & (rst & ~is_exception_mem | ~stall_memwb);
	 
    // for debug
	//wire debug_reg_we_wb;
	//assign debug_wb_pc = pc_wb;
	//assign debug_wb_rf_wen = {debug_reg_we_wb,debug_reg_we_wb,debug_reg_we_wb,debug_reg_we_wb};
    //assign debug_reg_we_wb = reg_we_wb & stall_memwb;
	//assign debug_wb_rf_wnum = rw_wb;
	//assign debug_wb_rf_wdata = reg_din_wb;

	assign rw_sel_id  		= control_id[8:7];
	assign r1_sel_id  		= control_id[4];
	assign r2_sel_id  		= control_id[5];
	assign ext_sel_id 		= control_id[14:13];
	assign r1_r_id    		= control_id[19];
	assign r2_r_id    		= control_id[20];

	assign aluop_ex      	= control_ex[3:0];
	assign alua_sel_ex   	= control_ex[16:15];
	assign alub_sel_ex   	= control_ex[18:17];
	assign load_ex       	= control_ex[21];
	assign add_sub_ex    	= control_ex[33:32];
	assign din_sel_ex    	= control_ex[11:9];
	assign load_store_ex 	= control_ex[31:29];
	assign hilo_mode_ex  	= control_ex[24:23];

	assign hilo_mode_mem    = control_mem[24:23];
	assign load_mem         = control_mem[21];
	assign eret_mem         = control_mem[27];
	assign break_mem        = control_mem[26];
	assign syscall_mem      = control_mem[25];
	assign invalid_inst_mem = control_mem[28];
	assign load_store_mem   = control_mem[31:29];
	assign din_sel_mem      = control_mem[11:9];
	assign not_nop_mem      = control_mem[22];

	assign hilo_mode_wb 	= control_wb[24:23];
	assign reg_we_wb 		= control_wb[6];
	assign cp0_we_wb 		= control_wb[12];
	assign din_sel_wb 		= control_wb[11:9];
	assign load_store_wb 	= control_wb[31:29];
	
	assign interrupt_flags 	= {hardware_int,software_int};

	//------------global----------
	always @(posedge aclk) begin
		rst <= aresetn;
	end
	
	reg pcif_new_ins_tocache;
	always@(posedge aclk)begin
		if(!rst)begin
			pcif_new_ins_tocache <= 1'b1;
		end else begin
			pcif_new_ins_tocache <= stall_pc;
		end
	end
	
	reg mem_new_ins_tocache;
	always@(posedge aclk)begin
		if(!rst)begin
			mem_new_ins_tocache <= 1'b1;
		end else begin
			mem_new_ins_tocache <= stall_exmem;
		end
	end
	
	
	//------global components------
	conflict u_conflict(
		.r1_r_id			(r1_r_id),
		.r2_r_id			(r2_r_id),
		.r1_id				(r1_id),
		.r2_id				(r2_id),
		.rw_ex				(rw_ex),
		.rw_mem				(rw_mem),
		.load_ex			(load_ex),
		.load_mem			(load_mem),
		.conflict_stall		(load_use)
    );

    // 指令地址变换
	addr_map u_addr_map_pc(
		.addr_in			(pc_if),
		.addr_out			(physical_pc)
	);

    // 数据地址变换
	addr_map u_addr_map_dm(
		.addr_in			(alu_r1_mem),
		.addr_out			(physical_dm_addr)
	);

	
	//------pipeline components------
	//------------IF stage-----------
	// cpu pc 计算
	pc u_pc(
		.clk				(aclk),
		.resetn				(rst_pc),
		
    	.pc_reg(pc_if),
    	.illegal_pc_if		(illegal_pc_if),

      	.pc_en				(stall_pc),
      	.branch_address		(bj_address_id),
      	.is_branch			(is_bj_id),
      	.is_exception		(is_exception_mem),
      	.exception_new_pc	(exception_new_pc_mem)
	);

	//------------IF_ID stage-----------
	IF_ID u_IF_ID(
	    .clk				(aclk),
		.rset				(rst_ifid),
		
	    .stall				(stall_ifid),
	    
	    .instruction_in		(instruction_if),
	    .PC_in				(pc_if),
	    .illegal_pc_in		(illegal_pc_if),
	    .in_delayslot_in 	(in_delayslot_if),

	    .instruction_out	(instruction_id),
	    .PC_out				(pc_id),
	    .illegal_pc_out		(illegal_pc_id),
	    .in_delayslot_out	(in_delayslot_id)
	);

	//--------------ID stage---------
	decoder u_decoder(
		.instruction		(instruction_id),

		.rs					(rs_id),
		.rt					(rt_id),
		.rd					(rd_id),
		.op					(op_id),
		.func				(func_id),
		.imm16				(imm16_id),
		.imm26				(imm26_id),
		.shamt				(shamt_id),
		.sel				(sel_id)
	);

	redirect_reg_id u_redirect_reg_id(
		.real_rdata1_id		(real_rdata1_id),
		.real_rdata2_id		(real_rdata2_id),
		
		.rdata1_id     		(rdata1_id),
		.rdata2_id     		(rdata2_id),
		.alu_r1_ex     		(alu_r1_ex_no_mult_ex),
		.alu_r1_mem    		(alu_r1_mem),
		.hilo_ex       		(hilo_ex),
		.hilo_mem      		(hilo_mem),
		.cp0_data_ex   		(cp0_data_ex),
		.cp0_data_mem  		(cp0_data_mem),
		.pc_ex         		(pc_ex),
		.pc_mem        		(pc_mem),
		.r1_r_id       		(r1_r_id),
		.r2_r_id       		(r2_r_id),
		.r1_id         		(r1_id),
		.r2_id         		(r2_id),
		.din_sel_ex    		(din_sel_ex),
		.din_sel_mem   		(din_sel_mem),
		.rw_ex         		(rw_ex),
		.rw_mem        		(rw_mem)
	);
	
	controller u_controller(
		.op					(op_id),
		.func				(func_id),
		.rs					(rs_id),
		.rt					(rt_id),
		.shamt      		(shamt_id),

		.control_bus		(control_id),
		.branch_jump		(bj_num_id),
		.in_delayslot		(in_delayslot_if)
	);

	extend u_extend(
		.ext_sel			(ext_sel_id),
		.shamt				(shamt_id),
		.imm16				(imm16_id),

		.imm32				(imm32_id)
	);

	regfiles u_regs(
		.clk				(aclk),
        .rst				(rst),
		
        .rdata1				(rdata1_id),
        .rdata2				(rdata2_id),

        .we					(reg_we_wb),
        .waddr				(rw_wb),
        .wdata				(reg_din_wb),
        .raddr1				(r1_id),
        .raddr2				(r2_id)
	);

	hilo_reg u_hilo_reg(
		.clk				(aclk),
        .resetn				(rst),
        
		.rdata				(hilo_id),
  
        .mode				(hilo_mode_wb),
        .rdata1_wb			(rdata1_wb),
        .alu_r1_wb			(alu_r1_wb),
        .alu_r2_wb			(alu_r2_wb)
    );

	reg_read_select u_reg_read_select(
		.rs_id				(rs_id),
		.rt_id				(rt_id),
		.r1_sel_id			(r1_sel_id),
		.r2_sel_id			(r2_sel_id),

		.r1					(r1_id),
		.r2					(r2_id)
    );

	reg_write_select u_reg_write_select(
		.rt_id				(rt_id),
		.rd_id				(rd_id),
		.rw_sel_id			(rw_sel_id),

		.rw					(rw_id)
    );

    Branch_Jump_ID	u_branch_jump(
	    .bj_type_ID			(bj_num_id),
	    .num_a_ID			(real_rdata1_id),
	    .num_b_ID			(real_rdata2_id),
	    .imm_b_ID			(imm16_id),
	    .imm_j_ID			(imm26_id),
	    .JR_addr_ID			(real_rdata1_id),
	    .PC_ID				(pc_id),

	    .Branch_Jump		(is_bj_id),
	    .BJ_address			(bj_address_id)
	);

	special_pop u_special_pop(
		.load_store			(load_store_ex),
		.alu_r1_ex			(alu_r1_ex),
		.not_nop_mem		(not_nop_mem),

		.special_pop		(special_pop)
	);

	//------------ID_EX stage---------
	ID_EX u_ID_EX(
		//input
	    .clk				(aclk),
		.rset				(rst_idex),
		
	    .stall				(stall_idex),
	    
	    .control_signal_in	(control_id),
	    .register1_in		(r1_id),
	    .register2_in		(r2_id),
	    .registerW_in		(rw_id),
	    .value_A_in			(real_rdata1_id),
	    .value_B_in			(real_rdata2_id),
	    .value_Imm_in		(imm32_id),
	    .PC_in				(pc_id),
	    .sel_in				(sel_id),
	    .HILO_in			(real_hilo_id),
	    .cp0_data_in		(cp0_data_id),
	    .cp0_rw_reg_in		(rd_id),
	    .illegal_pc_in     	(illegal_pc_id),
	    .in_delayslot_in   	(in_delayslot_id),
	
		//ouput
	    .control_signal_out	(control_ex),
	    .register1_out		(r1_ex),
	    .register2_out		(r2_ex),
	    .registerW_out		(rw_ex),
	    .value_A_out		(rdata1_ex),
	    .value_B_out		(rdata2_ex),
	    .value_Imm_out		(imm32_ex),
	    .PC_out				(pc_ex),
	    .sel_out			(sel_ex),
	    .HILO_out			(hilo_ex),
	    .cp0_data_out		(cp0_data_ex),
	    .cp0_rw_reg_out		(rd_ex),
	    .illegal_pc_out    	(illegal_pc_ex),
	    .in_delayslot_out  	(in_delayslot_ex)
	);

	//--------------EX stage---------
	ALU u_alu(
	    .X					(alu_a_ex),
	    .Y					(alu_b_ex),
	    .S					(aluop_ex),
	    .add_sub			(add_sub_ex),
	    .rst     			(rst),
	    .flush   			(is_exception_mem),
	    .clk     			(aclk),

		.Result1        	(alu_r1_ex),
		.Result2        	(alu_r2_ex),
		.Result1_no_mult	(alu_r1_ex_no_mult_ex),
		.Result2_no_mult	(alu_r2_ex_no_mult_ex),
	    .overflow			(overflow_ex),
	    .is_diving			(is_diving)
    );
    
    alu_select u_alu_select(
		.alua_sel_ex		(alua_sel_ex),
		.alub_sel_ex		(alub_sel_ex),
		.rdata1_ex			(rdata1_ex),
		.rdata2_ex			(rdata2_ex),
		.extern_ex			(imm32_ex),

		.alu_a				(alu_a_ex),
		.alu_b				(alu_b_ex)
    );

    redirect_hilo_id u_redirect_hilo_id(
    	.hilo_id      		(hilo_id),
    	.alu_r1_ex    		(alu_r1_ex),
    	.alu_r2_ex    		(alu_r2_ex),
    	.alu_r1_mem   		(alu_r1_mem),
    	.alu_r2_mem   		(alu_r2_mem),
    	.rdata1_ex    		(rdata1_ex),
    	.rdata1_mem   		(rdata1_mem),
    	.hilo_mode_ex 		(hilo_mode_ex),
    	.hilo_mode_mem		(hilo_mode_mem),
		
    	.real_hilo_id 		(real_hilo_id)
	);

	//------------EX_MEM stage---------	
	EX_MEM _EX_MEM(
		//input
	    .clk				(aclk),
		.rset				(rst_exmem),
	    .stall				(stall_exmem),
	    
	    .control_signal_in	(control_ex),
	    .registerW_in		(rw_ex),
	    .value_ALU_in	   	(alu_r1_ex),
	    .value_ALU2_in     	(alu_r2_ex),
	    .rdata1_in         	(rdata1_ex),
	    .rdata2_in		   	(rdata2_ex),
	    .PC_in				(pc_ex),
	    .sel_in				(sel_ex),
	    .HILO_in			(hilo_ex),
	    .cp0_data_in		(cp0_data_ex),
	    .cp0_rw_reg_in     	(rd_ex),
	    .overflow_in       	(overflow_ex),
	    .illegal_pc_in     	(illegal_pc_ex),
	    .in_delayslot_in   	(in_delayslot_ex),
	
		//ouput
	    .control_signal_out	(control_mem),
	    .registerW_out		(rw_mem),
	    .value_ALU_out 	   	(alu_r1_mem),
	   	.value_ALU2_out    	(alu_r2_mem),
	   	.rdata1_out        	(rdata1_mem),
	    .rdata2_out		   	(rdata2_mem),
	    .PC_out				(pc_mem),
	    .sel_out			(sel_mem),
	    .HILO_out			(hilo_mem),
	    .cp0_data_out		(cp0_data_mem),
	    .cp0_rw_reg_out    	(rd_mem),
	    .overflow_out      	(overflow_mem),
	    .illegal_pc_out    	(illegal_pc_mem),
	    .in_delayslot_out  	(in_delayslot_mem)
	);

	//------------MEM stage--------
	dram_mode u_dram_mode(
		.load_store_mem				(load_store_mem),
		.data_sram_addr_byte_mem	(alu_r1_mem[1:0]),

		.mode_mem					(mode_mem)
	);

	dm_in_select u_dm_in_select(
		.rdata2_mem					(rdata2_mem),
		.load_store_mem				(load_store_mem),
		.data_sram_addr_byte_mem	(alu_r1_mem[1:0]),

		.dram_wdata_mem				(dram_wdata_mem)
	);
	
	illegal_addr u_illegal_addr(
		.load_store_mem				(load_store_mem),
		.data_sram_addr_byte		(alu_r1_mem[1:0]),

		.dm_addr_illegal			(dm_addr_illegal_mem)
	);

	//-----------MEM_WB stage--------
	MEM_WB u_MEM_WB(
		//input
	    .clk				(aclk),
		.rset				(rst_memwb),
	    .stall				(stall_memwb),
	    
	    .control_signal_in	(control_mem),
	    .registerW_in		(rw_mem),
	    .value_ALU_in      	(alu_r1_mem),
	    .value_ALU2_in     	(alu_r2_mem),
	    .value_Data_in		(DMout_mem),
	    .PC_in				(pc_mem),
	    .sel_in				(sel_mem),
	    .HILO_in			(hilo_mem),
	    .cp0_data_in		(cp0_data_mem),
	    .rdata1_in         	(rdata1_mem),
	    .rdata2_in			(rdata2_mem),
	    .cp0_rw_reg_in		(rd_mem),
	
		//ouput
	    .control_signal_out	(control_wb),
	    .registerW_out		(rw_wb),
	    .value_ALU_out     	(alu_r1_wb),
	    .value_ALU2_out    	(alu_r2_wb),
	    .value_Data_out		(DMout_wb),
	    .PC_out				(pc_wb),
	    .sel_out			(sel_wb),
	    .HILO_out			(hilo_wb),
	    .cp0_data_out		(cp0_data_wb),
	    .rdata1_out        	(rdata1_wb),
	    .rdata2_out			(rdata2_wb),
	    .cp0_rw_reg_out		(rd_wb)
	);

	//-------------CP0---------------
	cp0 u_cp0(
		//input
	    .clk				(aclk),
	    .rst				(rst),
		
	    .stall          	(stall_exmem & stall_memwb),
		
	    .rd_addr			(rd_id),
	    .rd_sel				(sel_id),
	    .we					(cp0_we_wb),
	    .wr_addr			(rd_wb),
	    .wr_sel				(sel_wb),
	    .data_i				(rdata2_wb),
	    .hardware_int_in	(interrupt),

	    .clean_exl			(cp0_exl_mem),
	    .en_exp				(cp0_wr_exp_mem),
	    .exp_epc			(exp_epc_mem),
	    .exp_bd				(in_delayslot_mem),
	    .exp_code			(exception_code_mem),
	    .exp_bad_vaddr		(exp_bad_vaddr_mem),
	    .exp_badv_we		(cp0_badv_we_mem),
	    .exp_asid			(exp_asid_mem),
	    .exp_asid_we		(cp0_exp_asid_we_mem),
	    .ins_illegal    	(illegal_pc_mem),
	
		//output
	    .data_o				(cp0_data_id), 
	    .user_mode			( ),
	    .ebase				(ebase_id),
	    .epc				(epc_id),
	    .tlb_config			( ),
	    .allow_int			(allow_int_id),
	    .software_int_o		(software_int),
	    .hardware_int_o		(hardware_int),
	    .interrupt_mask		( ),
	    .special_int_vec	(special_int_vec_id),
	    .boot_exp_vec		(boot_exp_vec_id),
	    .asid				( ),
	    .int_exl			( ),
	    .kseg0_uncached		( )
	);

	//-------------exception---------------
	exception u_exception(
		//input
	   .invalid_inst		(invalid_inst_mem),
	   .syscall				(syscall_mem),
	   .break_inst			(break_mem),
	   .eret				(eret_mem),
	   .pc_value			(pc_mem),
	   .in_delayslot		(in_delayslot_mem),
	   .overflow			(overflow_mem),
	   .interrupt_flags		(interrupt_flags),
	   .allow_int			(allow_int_id),
	   .ebase_in			(ebase_id),
	   .epc_in				(epc_id),
	   .special_int_vec		(special_int_vec_id),
	   .boot_exp_vec		(boot_exp_vec_id),
	   .iaddr_exp_illegal	(illegal_pc_mem),
	   .daddr_exp_illegal	(dm_addr_illegal_mem),
	   .mem_data_vaddr		(alu_r1_mem),
	   .mem_data_we			(|mode_mem),
	   
		//output
	   .flush				(is_exception_mem),
	   .cp0_wr_exp			(cp0_wr_exp_mem),
	   .cp0_clean_exl		(cp0_exl_mem),
	   .exp_epc				(exp_epc_mem),
	   .exp_code			(exception_code_mem),
	   .exp_bad_vaddr		(exp_bad_vaddr_mem),
	   .cp0_badv_we			(cp0_badv_we_mem),
	   .exception_new_pc	(exception_new_pc_mem),
	   .exp_asid			(exp_asid_mem),
	   .cp0_exp_asid_we		(cp0_exp_asid_we_mem)
	);

	//--------------WB stage---------
	DMout_select_extend u_DMout_select_extend(
		.load_store_wb			(load_store_wb),
		.DMout_wb(DMout_wb),
		.data_sram_addr_byte_wb	(alu_r1_wb[1:0]),

		.real_DMout_wb			(real_DMout_wb)
	);

	reg_din_select u_reg_din_select(
		.alu_r_wb			(alu_r1_wb),
		.pc_wb				(pc_wb),
		.DMout_wb			(real_DMout_wb),
		.cp0_d1_wb			(cp0_data_wb),
		.HI_wb				(hilo_wb[63:32]),
		.LO_wb				(hilo_wb[31:0]),
		.reg_din_sel		(din_sel_wb),

		.reg_din			(reg_din_wb)
    );

	//-------------AXI4 interface-----------
	cpu_axi u_cpu_axi(
	    .clk				(aclk),
	    .rset				(rst & aresetn),
		
	    .cpu_d_addr			(physical_dm_addr),
		.cpu_d_byteenable	(mode_mem),
		.cpu_d_read			(load_mem),
		.cpu_d_write		(|mode_mem),
		.cpu_d_hitwriteback	(1'b0),
		.cpu_d_hitinvalidate(1'b0),
		.cpu_d_wrdata		(dram_wdata_mem),
		.cpu_d_rddata		(DMout_mem),
		.cpu_d_stall		(data_stall),
		.cpu_d_addr_illegel	(dm_addr_illegal_mem),
		.dcache_new_lw_ins	(mem_new_ins_tocache),
		
	    .cpu_i_addr			(physical_pc),
	    .cpu_i_byteenable	(4'b1111),
	    .cpu_i_read			(1'b1),
	    .cpu_i_hitinvalidate(1'b0),
	    .cpu_i_rddata		(instruction_if),
	    .cpu_i_stall		(ins_stall),
		.cpu_i_addr_illegel	(illegal_pc_if),
		.icache_new_lw_ins	(pcif_new_ins_tocache),
		
	    .axi_araddr			(araddr),
	    .axi_arburst		(arburst),
	    .axi_arcache		(arcache),
	    .axi_arid			(arid),
	    .axi_arlen			(arlen),
	    .axi_arlock			(arlock),
	    .axi_arprot			(arprot),
	    .axi_arsize			(arsize),
	    .axi_arvaild		(arvalid),
		.axi_arready		(arready),
		
	    .axi_rdata			(rdata),
	    .axi_rid			(rid),
	    .axi_rlast			(rlast),
	    .axi_rresp			(rresp),
	    .axi_rvalid			(rvalid),
		.axi_rready			(rready),
		
		.axi_awaddr			(awaddr),
	    .axi_awburst		(awburst),
	    .axi_awcache		(awcache),
	    .axi_awid			(awid),
	    .axi_awlen			(awlen),
	    .axi_awlock			(awlock),
	    .axi_awprot			(awprot),
	    .axi_awsize			(awsize),
	    .axi_awvalid		(awvalid),
	    .axi_awready		(awready),
		
		.axi_wdata			(wdata),
	    .axi_wlast			(wlast),
	    .axi_wstrb			(wstrb),
	    .axi_wvalid			(wvalid),
	    .axi_wid			(wid),
	    .axi_wready			(wready),
		
	    .axi_bid			(bid),
	    .axi_bresp			(bresp),
	    .axi_bvalid			(bvalid),	    
	    .axi_bready			(bready)
	);

endmodule
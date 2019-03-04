/*
**  作者：马翔
**  功能：AXI总线
**  原创
*/
module AXI_interface(
    input wire 						clk,
    input wire 						rset,
	
    input wire 	[31:0]				i_addr,
    input wire 						i_addr_valid,
    input wire 						i_we,
    input wire 	[2:0]				i_size,
    input wire 	[7:0]				i_lens,
    input wire 						i_rready,
    output 							i_valid_clear,			//icache的有效信号清空信号
    output 							i_rd_dready,			//cache的写使能信号
    output 		[31:0]				i_rd_data,				//送往icache的数据
    output 							i_rlast,				//icache最后一次读
    input wire 	[31:0]				d_addr,
    input wire 						d_addr_valid,
    input wire 						d_we,
    input wire 	[2:0]				d_size,
    input wire 	[7:0]				d_lens,
    input wire 						d_rready,
    input wire 	[31:0]				d_wr_data,
    input wire 						d_wr_valid,
    input wire 	[3:0]				d_byte_enable,
    input wire 						d_resp_ready,
    input wire 						d_wr_wlast,
	
    //dcache output
    output 							d_valid_clear,
    output 							d_rd_dready,
    output 		[31:0]				d_rd_data,
    output reg 						d_wr_next,				//dcache的一次写完成信号，可以传输下一字节
    output reg 						d_wr_finish,			//dcache的写完成信号
    output 							d_rlast,				//dcache的最后一次读

    //axi通道接口参数
    //read addr channel
    output 		[31:0]				axi_araddr,
    output 		[1:0]				axi_arburst,
    output 		[3:0]				axi_arcache,
    output 		[3:0]				axi_arid,
    output 		[7:0]				axi_arlen,
    output 		[1:0]				axi_arlock,
    output 		[2:0]				axi_arprot,
    input wire 						axi_arready,
    output 		[2:0]				axi_arsize,
    output reg 						axi_arvalid,
    //write addr channel
    output 		[31:0]				axi_awaddr,
    output 		[1:0]				axi_awburst,
    output 		[3:0]				axi_awcache,
    output 		[3:0]				axi_awid,
    output 		[7:0]				axi_awlen,
    output 		[1:0]				axi_awlock,
    output 		[2:0]				axi_awprot,
    input wire 						axi_awready,
    output 		[2:0]				axi_awsize,
    output reg 						axi_awvalid,
    //write response channel
    input wire 	[3:0]				axi_bid,
    output reg 						axi_bready,
    input wire 	[1:0]				axi_bresp,
    input wire 						axi_bvalid,
    //read data channel
    input wire 	[31:0]				axi_rdata,
    input wire 	[3:0]				axi_rid,
    input wire 						axi_rlast,
    output reg 						axi_rready,
    input wire 	[1:0]				axi_rresp,
    input wire 						axi_rvalid,
    //write data channel
    output 		[3:0]				axi_wid,
    output 		[31:0]				axi_wdata,
    output 							axi_wlast,
    input wire 						axi_wready,
    output 		[3:0]				axi_wstrb,
    output reg 						axi_wvalid
);

    reg 		[3:0] 				arbiter_id;				//仲裁控制信号

    wire 		[2:0]				temp_arsize;
    wire 		[2:0]				temp_awsize;
    wire 		[31:0]				temp_awaddr;
    wire 		[31:0]				temp_araddr;
    wire 		[7:0]				temp_awlens;
    wire 		[7:0]				temp_arlens;
    
    wire ar_enter = axi_arvalid & axi_arready;				//读地址握手成功
    wire r_retire = axi_rvalid  & axi_rready & axi_rlast;	//最后一次读数据握手成功
    wire aw_enter = axi_awvalid & axi_awready;				//写地址握手成功
    wire w_enter  = axi_wvalid  & axi_wready & axi_wlast;	//最后一次写数据握手成功
    wire b_retire = axi_bvalid  & axi_bready;				//写响应握手成功

    parameter ST0 = 0, ST1 = 1, ST2 = 2, ST3 = 3;
    reg 		[1:0] 				write_state;
    reg 							read_state;
	
	reg 							wr_clear; 
    reg 							rd_clear; 

	wire 							rd_lock;				//读通道锁信号
    wire 							wr_lock;				//写通道锁信号

    assign axi_awaddr = temp_awaddr;
    assign axi_araddr = temp_araddr;
    assign axi_arsize = 3'b010;								//一次传输一个字
    assign axi_awsize = temp_awsize;

    assign axi_arlen = temp_arlens;
    assign axi_arburst = 2'b01;
    assign axi_arlock = 0;
    assign axi_arcache = 0;
    assign axi_arprot = 3'b000;
    assign axi_arid = 0;
    assign axi_awid = 4'b0000;
    assign axi_awlen = temp_awlens;
    assign axi_awburst = 2'b01;
    assign axi_awlock = 0;
    assign axi_awcache = 0;
    assign axi_awprot = 3'b000;
    assign axi_wid = 4'b0000;
    assign d_rd_data = axi_rdata;
    assign i_rd_data = axi_rdata;
    assign axi_wdata = d_wr_data;							//默认为只有dcache具有写权限
    assign axi_wstrb = d_byte_enable;
    assign axi_wlast = d_wr_wlast;

    assign d_rd_dready = (axi_rvalid & d_rready & arbiter_id[1]) ? 1:0;
    assign i_rd_dready = (axi_rvalid & i_rready & arbiter_id[3]) ? 1:0;
    
    assign i_rlast = axi_rlast;
    assign d_rlast = axi_rlast;
    assign d_valid_clear = ((rd_clear & arbiter_id[1]) || wr_clear) ? 1:0;
    assign i_valid_clear = (rd_clear & arbiter_id[3]) ? 1:0;
    
    assign temp_awaddr  = ~rset ? 0 : d_addr;

    assign temp_araddr  = ~rset ? 0 : d_addr_valid & ~d_we ? d_addr :
                                      i_addr_valid & ~i_we ? i_addr : 0;
									  
    assign temp_awsize  = ~rset ? 0 : d_size;
    assign temp_awlens  = ~rset ? 0 : d_lens;
    assign temp_arsize  = ~rset ? 0 : d_addr_valid & ~d_we ? d_size :
                                      i_addr_valid & ~i_we ? i_size : 0;
									  
    assign temp_arlens  = ~rset ? 0 : d_addr_valid & ~d_we ? d_lens :
                                      i_addr_valid & ~i_we ? i_lens : 0;
									  
    always@(posedge clk)begin
        arbiter_id[0] <= ~rset ? 0: wr_lock ? arbiter_id[0] : d_addr_valid & d_we ? 1 : 0;
        arbiter_id[1] <= ~rset ? 0: rd_lock ? arbiter_id[1] : d_addr_valid & ~d_we & ~arbiter_id[3] ? 1 : 0;
        arbiter_id[2] <= 0;
        arbiter_id[3] <= ~rset ? 0: rd_lock ? arbiter_id[3] : d_addr_valid & ~d_we & ~arbiter_id[3] ? 0 :
                                                              i_addr_valid & ~i_we & ~arbiter_id[1] ? 1 : 0;
    end
	
    assign rd_lock = r_retire ? 0: (arbiter_id[1]||arbiter_id[3]) ? 1:0;
    assign wr_lock = b_retire ? 0: (arbiter_id[0]||arbiter_id[2]) ? 1:0;
  
    //read
    always @(posedge clk) begin
        if (~rset) begin
            // reset
            read_state <= 0;
            axi_arvalid <= 0; 
            axi_rready <= 0;
            rd_clear <= 0;
        end
        else begin
            case(read_state)
                ST0:begin//读地址握手阶段
                    axi_arvalid <= ar_enter? 0:(arbiter_id[1]||arbiter_id[3]);
                    read_state <= ar_enter ? 1:0;
                    axi_rready <= ar_enter ? 1:0;
                    rd_clear <= ar_enter ? 1:0;
                end
                ST1:begin//读数据握手阶段
                    axi_arvalid <= 0;
                    rd_clear <= 0;
                    axi_rready <= r_retire ? 0:axi_rready;
                    read_state <= r_retire ? 0:1;
                end
            endcase
        end
    end

    //write
    always @(posedge clk) begin
        if (~rset) begin
            // reset
            write_state <= 0;
            d_wr_finish <= 0;
            d_wr_next <= 0;
            wr_clear <= 0;
            axi_bready <= 0;
            axi_awvalid <= 0;
            axi_wvalid <= 0;
        end
        else begin
            case(write_state)
                ST0:begin//写地址握手阶段
                    axi_awvalid <= aw_enter ? 0:(arbiter_id[0]||arbiter_id[2]);
                    write_state <= aw_enter ? 1:0;
                    d_wr_finish <= 0;
                    wr_clear <= aw_enter ? 1:0;
                    axi_bready <= 0;
                end
                ST1:begin//写数据握手阶段
                    wr_clear <= 0;
                    axi_wvalid <= (axi_wvalid && axi_wready)? 0:d_wr_valid;
                    axi_awvalid <= 0;
                    write_state <= w_enter ? 2:1;
                    d_wr_next <= axi_wlast ? 0:
                                ((axi_wvalid && axi_wready)? 1 : 0);
                    d_wr_finish <= w_enter ? 1:0;
                    axi_bready <= w_enter ? 1:0;
                //写最后一帧数据完成时，提前发出CPU停机释放信号，由总线单方面挂起，等待写响应
                end
                ST2:begin//写数据完成阶段
                    wr_clear <= 0;
                    axi_wvalid <= 0;
                    write_state <= b_retire ? 0 : 2;
                    d_wr_finish <= 0;
                    axi_bready <= b_retire ? 0:1;
                end
                default:begin
                    write_state <= 0;
                end
            endcase
        end
    end

endmodule
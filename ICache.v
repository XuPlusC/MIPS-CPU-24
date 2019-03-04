/*
**  作者：林力韬
**  功能：数据cache\指令cache\uncache，与AXI接口对接实现AXI协议
*/

/*
icache实现的是一个不带有uncache访问功能的cache,总是cacheable,可用于指令cache，
内部只有dcache模块实例化，不需要选择访存请求经过的模块
*/

module ICache #(parameter
	CACHE_LINE_WIDTH = 6,	//CacheLine的大小，字节地址，减去2等于offset长度，该值不能大于9
	TAG_WIDTH = 20,	//Tag的长度
	NUM_ROADS = 2	//组相联路数
	`define NUM_CACHE_GOUPS (2 ** `INDEX_WIDTH)
) (
	// Clock and reset
	input  wire rst,
	input  wire clk,

	// AXI Bus 
	//input
    input wire AXI_rd_dready,//读访问，总线上数据就绪可写Cache的控制信号
    input wire AXI_rd_last,//读访问,标识总线上当前数据是最后一个数据字的控制信号
    input wire[31:0] AXI_rd_data,//读访问总线给出的数据
    input wire AXI_rd_addr_clear,//读请求地址已经被响应信号

    input wire AXI_wr_next,//写访问，总线允许送下一个数据的控制信号
    input wire AXI_wr_ok,//写访问，总线标识收到从设备最后一个ACK的控制信号
    input wire AXI_wr_addr_clear,//写请求地址已经被响应信号

    //output
    output wire [31:0]AXI_addr,//送总线地址；
    output wire  AXI_addr_valid,//送总线地址有效的控制信号
    output wire  AXI_we,//送总线标记访问是读还是写的控制信号
    output wire [2:0]AXI_size,
    output wire [7:0]AXI_lens,//读访问，送总线size/length
    output wire  AXI_rd_rready,//送总线，主设备就绪读数据的控制信号

    output wire [31:0]AXI_wr_data,//写访问，送总线的数据
    output wire AXI_wr_dready,//写访问，送总线一个字数据就绪的控制信号
    output wire [3:0]AXI_byte_enable,//写访问，送总线写字节使能的控制信号
    output wire AXI_wr_last,//写访问，送总线表示当前数据是最后一个数据字的控制信号
    output wire AXI_response_rready,//写访问，送总线表示就绪接收从设备ACK的信号

	// CPU i/f
	input  wire [31:0] cpu_addr,//CPU访问地址
	input  wire [3:0]  cpu_byteenable,//CPU访问模式
	input  wire        cpu_read,//CPU读命令
	input  wire        cpu_write,//CPU写命令
	input  wire        cpu_hitwriteback,//CPU强制写穿命令
	input  wire        cpu_hitinvalidate,//CPU强制失效命令
	input  wire [31:0] cpu_wrdata,//CPU写数据
	output wire [31:0] cpu_rddata,//发往CPU读到的数据
	output wire        cpu_stall,//发往CPU停机等待信号

	input  wire        cpu_addr_illegal,//CPU地址错信号
	input  wire        new_lw_ins_tocache//CPU上一周期正常运转，到达Cache的是新的访存请求信号
);

	//如果illegal 终止访存，取消CPU访存指令
	wire addr_illegal;
	wire [3:0] legal_cpu_byteenable;
	wire legal_cpu_read;
	wire legal_cpu_write;
	wire legal_cpu_hitwriteback;
	wire legal_cpu_hitinvalidate;
	assign addr_illegal = cpu_addr_illegal;
	assign legal_cpu_byteenable = addr_illegal? 4'b0000 : cpu_byteenable;
	assign legal_cpu_read = addr_illegal? 0 : cpu_read;
	assign legal_cpu_write = addr_illegal? 0 : cpu_write;
	assign legal_cpu_hitwriteback = addr_illegal? 0 : cpu_hitwriteback;
	assign legal_cpu_hitinvalidate = addr_illegal? 0 : cpu_hitinvalidate;

	//信号声明
    wire DCache_AXI_rd_dready;
    wire DCache_AXI_rd_last;
    wire [31:0] DCache_AXI_rd_data;
    wire DCache_AXI_rd_addr_clear;
    wire DCache_AXI_wr_next;
    wire DCache_AXI_wr_ok;
    wire DCache_AXI_wr_addr_clear;
    wire [31:0]DCache_AXI_addr;
    wire DCache_AXI_addr_valid;
    wire DCache_AXI_we;
    wire [2:0]DCache_AXI_size;
    wire [7:0]DCache_AXI_lens;
    wire DCache_AXI_rd_rready;
    wire [31:0]DCache_AXI_wr_data;
    wire DCache_AXI_wr_dready;
    wire[3:0]DCache_AXI_byte_enable;
    wire DCache_AXI_wr_last;
    wire DCache_AXI_response_rready;
	wire [31:0] DCache_cpu_addr;
	wire [3:0]  DCache_cpu_byteenable;
	wire DCache_cpu_read;
	wire DCache_cpu_write;
	wire DCache_cpu_hitwriteback;
	wire DCache_cpu_hitinvalidate;
	wire [31:0] DCache_cpu_wrdata;
	wire [31:0] DCache_cpu_rddata;
	wire        DCache_cpu_stall;

	//总是使用DCache输入输出
	//input
	assign DCache_AXI_rd_dready = AXI_rd_dready;
	assign DCache_AXI_rd_last = AXI_rd_last;
	assign DCache_AXI_rd_data = AXI_rd_data;
	assign DCache_AXI_rd_addr_clear = AXI_rd_addr_clear;

	assign DCache_AXI_wr_next = AXI_wr_next;
	assign DCache_AXI_wr_ok = AXI_wr_ok;
	assign DCache_AXI_wr_addr_clear = AXI_wr_addr_clear;

    //output
    assign AXI_addr =  DCache_AXI_addr ;//送总线地址；
    assign AXI_addr_valid =  DCache_AXI_addr_valid ;//送总线地址有效的控制信号
    assign AXI_we =  DCache_AXI_we ;//送总线标记访问是读还是写的控制信号
    assign AXI_size =  DCache_AXI_size ;
    assign AXI_lens =  DCache_AXI_lens ;//读访问，送总线size/length
    assign AXI_rd_rready =DCache_AXI_rd_rready ;//送总线，主设备就绪读数据的控制信号

    assign AXI_wr_data =  DCache_AXI_wr_data ;//写访问，送总线的数据
    assign AXI_wr_dready =  DCache_AXI_wr_dready ;//写访问，送总线一个字数据就绪的控制信号
    assign AXI_byte_enable =  DCache_AXI_byte_enable ;//写访问，送总线写字节使能的控制信号
    assign AXI_wr_last =  DCache_AXI_wr_last ;//写访问，送总线表示当前数据是最后一个数据字的控制信号
    assign AXI_response_rready =  DCache_AXI_response_rready ;

	// CPU i/f
	assign DCache_cpu_byteenable =  legal_cpu_byteenable ;//CPU访问模式
	assign DCache_cpu_read =  legal_cpu_read ;//CPU读命令
	assign DCache_cpu_write =  legal_cpu_write ;//CPU写命令
	assign DCache_cpu_hitwriteback =  legal_cpu_hitwriteback ;//CPU强制写穿命令
	assign DCache_cpu_hitinvalidate =  legal_cpu_hitinvalidate ;//CPU强制失效命令

	wire [31:0]cpu_addr_real;
	assign cpu_addr_real = {cpu_addr[31:2],2'b00};
	assign DCache_cpu_addr = cpu_addr_real;
	assign DCache_cpu_wrdata = cpu_wrdata;

	//CPU output
	assign cpu_rddata = addr_illegal? 0: DCache_cpu_rddata ;//发往CPU读到的数据
	assign cpu_stall = DCache_cpu_stall ;//发往CPU停机等待信号

	DCache #(
		.CACHE_LINE_WIDTH(CACHE_LINE_WIDTH),	//CacheLine的大小，字节地址，减去2等于offset长度，该值不能大于9
		.TAG_WIDTH (TAG_WIDTH),	//Tag的长度
		.NUM_ROADS(NUM_ROADS)	//组相联路数
	) u_inter_ICache(
		// Clock and reset
		.rst(rst),.clk(clk),
		// AXI Bus 
		//input
	    .AXI_rd_dready(DCache_AXI_rd_dready),//读访问，总线上数据就绪可写Cache的控制信号
	    .AXI_rd_last(DCache_AXI_rd_last),//读访问,标识总线上当前数据是最后一个数据字的控制信号
	    .AXI_rd_data(DCache_AXI_rd_data),//读访问总线给出的数据
	    .AXI_rd_addr_clear(DCache_AXI_rd_addr_clear),//读请求地址已经被响应信号

	    .AXI_wr_next(DCache_AXI_wr_next),//写访问，总线允许送下一个数据的控制信号
	    .AXI_wr_ok(DCache_AXI_wr_ok),//写访问，总线标识收到从设备最后一个ACK的控制信号
	    .AXI_wr_addr_clear(DCache_AXI_wr_addr_clear),//写请求地址已经被响应信号

	    //output
	    .AXI_addr(DCache_AXI_addr),//送总线地址；
	    .AXI_addr_valid(DCache_AXI_addr_valid),//送总线地址有效的控制信号
	    .AXI_we(DCache_AXI_we),//送总线标记访问是读还是写的控制信号
	    .AXI_size(DCache_AXI_size),
	    .AXI_lens(DCache_AXI_lens),//读访问，送总线size/length
	    .AXI_rd_rready(DCache_AXI_rd_rready),//送总线，主设备就绪读数据的控制信号

	    .AXI_wr_data(DCache_AXI_wr_data),//写访问，送总线的数据
	    .AXI_wr_dready(DCache_AXI_wr_dready),//写访问，送总线一个字数据就绪的控制信号
	    .AXI_byte_enable(DCache_AXI_byte_enable),//写访问，送总线写字节使能的控制信号
	    .AXI_wr_last(DCache_AXI_wr_last),//写访问，送总线表示当前数据是最后一个数据字的控制信号
	    .AXI_response_rready(DCache_AXI_response_rready),

		// CPU i/f
		.cpu_addr(DCache_cpu_addr),//CPU访问地址
		.cpu_byteenable(DCache_cpu_byteenable),//CPU访问模式
		.cpu_read(DCache_cpu_read),//CPU读命令
		.cpu_write(DCache_cpu_write),//CPU写命令
		.cpu_hitwriteback(DCache_cpu_hitwriteback),//CPU强制写穿命令
		.cpu_hitinvalidate(DCache_cpu_hitinvalidate),//CPU强制失效命令
		.cpu_wrdata(DCache_cpu_wrdata),//CPU写数据
		.cpu_rddata(DCache_cpu_rddata),//发往CPU读到的数据
		.cpu_stall(DCache_cpu_stall)//发往CPU停机等待信号
	);

endmodule


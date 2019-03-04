/*
**  作者：林力韬
**  功能：数据cache\指令cache\uncache，与AXI接口对接实现AXI协议
*/

/*
uncache模块包含有AXI状态机，通过和AXI interface模块交互，实现AXI协议的功能。
使得CPU可以直接访问AXI总线，但一次传输一个字，没有实现非对齐访问。
*/

`define CACHE_FSM_IDLE					3'd0
`define CACHE_FSM_WRITEBACK_WAIT		3'd1
`define CACHE_FSM_WRITEBACK				3'd3
`define CACHE_FSM_MEMREAD_WAIT			3'd4
`define CACHE_FSM_MEMREAD				3'd5
`define CACHE_FSM_WAIT_WRITE			3'd6
`define CACHE_FSM_WRITEBACK_WAITOVER	3'd7

`define AXI_1bytes_SIZE 				3'b000
`define AXI_2bytes_SIZE 				3'b001
`define AXI_4bytes_SIZE 				3'b010
`define AXI_8bytes_SIZE 				3'b011
`define AXI_16bytes_SIZE 				3'b100
`define AXI_32bytes_SIZE 				3'b101
`define AXI_64bytes_SIZE 				3'b110
`define AXI_128bytes_SIZE 				3'b111

module UnCache(
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
    output reg  AXI_addr_valid,//送总线地址有效的控制信号
    output reg  AXI_we,//送总线标记访问是读还是写的控制信号
    output wire [2:0]AXI_size,
    output wire [7:0]AXI_lens,//读访问，送总线size/length
    output reg  AXI_rd_rready,//送总线，主设备就绪读数据的控制信号

    output wire [31:0]AXI_wr_data,//写访问，送总线的数据
    output reg AXI_wr_dready,//写访问，送总线一个字数据就绪的控制信号
    output reg [3:0]AXI_byte_enable,//写访问，送总线写字节使能的控制信号
    output reg AXI_wr_last,//写访问，送总线表示当前数据是最后一个数据字的控制信号
    output reg AXI_response_rready,

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
	input  wire        cpu_new_ins

);
	//AXI SIZE MAP
	assign AXI_size = `AXI_4bytes_SIZE;
	assign AXI_lens = 8'b0;//一次突发只发送一次数据

	//状态机
	reg [2:0] state;
	//reg dirty;
	reg stall_valid;
	assign AXI_wr_data = cpu_wrdata;//传输的数据
	assign AXI_addr = cpu_addr;
	// To cpu
	assign cpu_stall = (
		(state != `CACHE_FSM_IDLE ||
		((state == `CACHE_FSM_IDLE) && cpu_new_ins && (cpu_read || cpu_write))) && ~stall_valid
	);

	reg[31:0] mem_rd_data;
	assign cpu_rddata = mem_rd_data;

	// FSM controller
	always @(posedge clk, negedge rst) begin
		if (~rst) begin //异步复位，同步动作
			//AXI总线空闲
			AXI_addr_valid<=1'b0;
			//总线信号清除
			AXI_response_rready<=0;
			AXI_we<=1'b0;
			AXI_rd_rready<=1'b0;
			AXI_wr_dready<=1'b0;
			AXI_byte_enable<=4'b0000;
			AXI_wr_last<=1'b0;
			//内部寄存器清零
			mem_rd_data<=0;
			state <= `CACHE_FSM_IDLE;
			stall_valid <= 0;
		end else begin
			case (state)
				`CACHE_FSM_IDLE: begin
					stall_valid <= 0;
					if (cpu_write && cpu_new_ins) begin
						//地址,数据总是就绪
						//总线信号操作
						AXI_byte_enable<=cpu_byteenable;
						AXI_we <= 1'b1;
						AXI_addr_valid <= 1'b1;
						AXI_wr_dready <= 1'b1;
						AXI_wr_last<=1;//发送完成ACK
						AXI_response_rready <= 1;
						state <= `CACHE_FSM_WRITEBACK_WAITOVER;
					end else if (cpu_read && cpu_new_ins) begin //访存优先级低于替换，先替换后访存
						state <= `CACHE_FSM_MEMREAD_WAIT;
						//地址总是就绪
						//总线信号操作
						AXI_byte_enable<=cpu_byteenable;
						AXI_we <= 1'b0;
						AXI_addr_valid <= 1'b1;
						AXI_rd_rready <=1'b1;
					end
				end

				`CACHE_FSM_WRITEBACK_WAITOVER: begin
					if(AXI_wr_addr_clear)begin
						//撤销总线请求信号
						AXI_addr_valid <= 1'b0;
					end
					if (AXI_wr_ok == 1'b1) begin //总线传输结束
						AXI_wr_dready <= 1'b0;
						AXI_addr_valid <= 1'b0;
						AXI_response_rready <= 0;
						AXI_byte_enable<=4'b0000;
						AXI_wr_last <=0;
						AXI_we <= 1'b0;
						//dirty <= 0;
						state <= `CACHE_FSM_IDLE;
						stall_valid <= 1;
					end
					//若总线无响应则等待
				end

				`CACHE_FSM_MEMREAD_WAIT: begin
					if(AXI_rd_addr_clear)begin
						//撤销总线请求信号
						AXI_addr_valid <= 1'b0;
					end
					if (AXI_rd_dready == 1'b1) begin //总线有数据
                        //记录送达的数据
						mem_rd_data<= AXI_rd_data;
						//撤销总线请求信号，但CPU继续停等
						AXI_addr_valid <= 1'b0;
						//总线信号操作
						AXI_rd_rready <= 1'b0;
						AXI_byte_enable<=4'b0000;
						state <= `CACHE_FSM_IDLE;
					end
				end
				default: begin
					state <= `CACHE_FSM_IDLE;
				end
			endcase
		end
	end

endmodule
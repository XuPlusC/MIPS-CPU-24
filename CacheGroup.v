/*
**  作者：林力韬
**  功能：数据cache\指令cache\uncache，与AXI接口对接实现AXI协议
*/

/*
cache组是cache最重要的模块，其主要功能是实现命中查找、随机替换策略、寻找空的cache行等等
注意，MIPS体系结构中cache指令中有全组选中失效或同步的功能，cachegroup模块没有实现这一功能
多个cache_group构成cache整体，由地址的INDEX字段索引
*/
module CacheGroup #(parameter
	CACHE_LINE_WIDTH = 6,
	TAG_WIDTH = 18,
	NUM_ROADS = 2	//组相联路数
	`define OFFSET_WIDTH (CACHE_LINE_WIDTH-2)//注意，OFFSET_WIDTH不能长于7位，即每Cache行不大于128B
) (
	// Clock and reset
	input  wire rst,
	input  wire clk,
	//目标地址与目标偏移
	input  wire [`OFFSET_WIDTH-1:0] rd_off,
	input  wire [TAG_WIDTH-1:0] rd_aim_tag,
	input  wire [31:0] rand,
	//读出的数据
	output wire [TAG_WIDTH-1:0]     rd_tag_output,
	output wire [31:0]              rd_data_output,
	output wire                     rd_dirty_output,
	output wire                     rd_valid_output,
	output wire 					rd_hit_output,
	output wire 					full,
	//需要写入的数据
	input  wire                     write_cache,
	input  wire [`OFFSET_WIDTH-1:0] wr_off,
	input  wire [TAG_WIDTH-1:0]     wr_tag,
	input  wire [31:0]              wr_data,
	input  wire [3:0]               wr_byte_enable,
	input  wire                     wr_dirty,
	input  wire                     wr_valid
);

	// Wires to cache lines
	wire [TAG_WIDTH-1:0]     rd_tag[NUM_ROADS-1:0];
	wire [31:0]              rd_data[NUM_ROADS-1:0];
	wire                     rd_dirty[NUM_ROADS-1:0];
	wire                     rd_valid[NUM_ROADS-1:0];
	wire                     wr_write[NUM_ROADS-1:0];

	// Storage
	genvar i;
	generate for (i = 0; i < NUM_ROADS; i = i + 1) begin
	CacheLine #(
		.CACHE_LINE_WIDTH (CACHE_LINE_WIDTH),
		.TAG_WIDTH        (TAG_WIDTH)
	) lines (
		.rst(rst), .clk(clk),

		.rd_tag(rd_tag[i]), .rd_off(rd_off),
		.rd_data(rd_data[i]), .rd_dirty(rd_dirty[i]),
		.rd_valid(rd_valid[i]),

		.wr_write(wr_write[i]),
		.wr_tag(wr_tag), .wr_off(wr_off),
		.wr_data(wr_data), .wr_byte_enable(wr_byte_enable),
		.wr_dirty(wr_dirty), .wr_valid(wr_valid)
	);
	end endgenerate

	//获取命中情况下的数据
	wire [TAG_WIDTH-1:0]     rd_tag_hit;
	wire [31:0]              rd_data_hit;
	wire                     rd_dirty_hit;
	wire                     rd_valid_hit;
	reg [31:0]				 rd_tag_index;
	reg [31:0]               j;
	
	always @(*) begin
		//从rd_tag[i],rd_data[i],rd_dirty[i],rd_valid[i]选择rd_tag[i]==rd_aim_tag的CacheLine
		rd_tag_index <= 0;
		 for (j = 0; j < NUM_ROADS; j = j + 1) begin
			if(rd_tag[j]==rd_aim_tag & rd_valid[j]) begin
				rd_tag_index <= j;
			end
		end 
	end
	
	assign rd_tag_hit = rd_tag[rd_tag_index];
	assign rd_data_hit = rd_data[rd_tag_index];
	assign rd_dirty_hit = rd_dirty[rd_tag_index];
	assign rd_valid_hit = rd_valid[rd_tag_index];

	assign rd_hit_output = rd_valid_hit && (rd_tag_hit == rd_aim_tag) ;

	//获取随机情况下的数据
	wire[31:0] rand_id;
	assign rand_id = rand;
	reg [TAG_WIDTH-1:0]     rd_tag_rand;
	reg [31:0]              rd_data_rand;
	reg                     rd_dirty_rand;
	reg                     rd_valid_rand;
	always @(*) begin
		rd_tag_rand <= rd_tag[rand_id];
		rd_data_rand <= rd_data[rand_id];
		rd_dirty_rand <= rd_dirty[rand_id];
		rd_valid_rand <= rd_valid[rand_id];
	end
	
	//计算首个INVALID的空行位置,并计算是否没有空行
	wire 	rd_invalid_we[NUM_ROADS-1:0];
	wire 	rd_invalid_temp[NUM_ROADS-1:0];
	//wire 	full;
	generate for (i = 0; i < NUM_ROADS; i = i + 1) begin
		if(i==0)	begin 
			assign rd_invalid_we[i]=~rd_valid[i];
			assign rd_invalid_temp[i]=rd_invalid_we[i];
		end else if(i>0) 	
			begin assign rd_invalid_we[i]=~rd_valid[i] & ~rd_invalid_temp[i-1];
			assign rd_invalid_temp[i]=rd_invalid_we[i] | rd_invalid_temp[i-1];
		end
	end endgenerate
	
	assign full = ~rd_invalid_temp[NUM_ROADS-1];


	//在hit\invalid\rand中选中一个送到输出
	assign rd_tag_output = rd_hit_output?rd_tag_hit:(full?rd_tag_rand:0);
	assign rd_data_output = rd_hit_output?rd_data_hit:(full?rd_data_rand:0);
	assign rd_dirty_output = rd_hit_output?rd_dirty_hit:(full?rd_dirty_rand:0);
	assign rd_valid_output = rd_hit_output?rd_valid_hit:(full?rd_valid_rand:0);


	//对tag命中的行,给出写使能选择信号;未命中写使能信号给空行,若已满给随机一行
	wire   wr_write_hit[NUM_ROADS-1:0];
	wire   wr_write_rand[NUM_ROADS-1:0];
	wire   wr_write_invalid[NUM_ROADS-1:0];
	generate for (i = 0; i < NUM_ROADS; i = i + 1) begin
		assign wr_write_hit[i] = write_cache ? ((rd_tag[i] == rd_aim_tag) && rd_valid[i]) : 1'b0;
		assign wr_write_rand[i] = write_cache ? (i == rand_id):1'b0;
		assign wr_write_invalid[i] = write_cache ? rd_invalid_we[i]:1'b0;
		assign wr_write[i] = rd_hit_output?wr_write_hit[i]:(full?wr_write_rand[i]:wr_write_invalid[i]);
	end endgenerate

endmodule

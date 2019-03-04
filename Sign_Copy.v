/*
**  作者：林力韬
**  功能：数据cache\指令cache\uncache，与AXI接口对接实现AXI协议
*/

/*
Sign_Copy模块将一个输入数据拷贝到2个寄存器中，用于电路扇出优化
这里使用DONT_TOUCH = "true"命令防止VIVADO综合布线时将该模块优化掉
*/

(*DONT_TOUCH = "true"*)  module Sign_Copy#(
	parameter  SIGN_WIDTH = 1)(
	input		[SIGN_WIDTH-1:0]  need_copy,
	output reg  [SIGN_WIDTH-1:0]  copy_sign_1,
	output reg  [SIGN_WIDTH-1:0]  copy_sign_0
);

    always @(need_copy) begin
        copy_sign_1 <= need_copy;
        copy_sign_0 <= need_copy;
    end 
	
endmodule

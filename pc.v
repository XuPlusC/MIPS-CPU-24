/*
**  作者：林力韬
**  修改：张鑫
**  功能：程序计数器
**  地址转移逻辑照搬清华大学，但增加了pc地址异常检测
*/
module pc(
	input wire 			clk,
	input wire 			resetn,
    
    input wire 			pc_en,
    input wire[31:0] 	branch_address, 	//来自分支模块的跳转地址
    input wire 			is_branch, 			//分支模块跳转信号
    input wire 			is_exception, 		//异常模块跳转信号
    input wire[31:0] 	exception_new_pc, 	//来自异常模块的跳转地址
	
	output reg[31:0] 	pc_reg,
    output 				illegal_pc_if
);
    
	parameter PC_INITIAL = 32'hbfc00000; //第一条指令开始执行的位置

    reg[31:0] pc_next;
    
    //非对齐指令地址，即低2位不为0视作异常，信号随流水段传至MEM段异常处理模块
	assign illegal_pc_if = pc_reg[1] | pc_reg[0]; 

    always @(*) begin
        if (!resetn) begin
          pc_next <= PC_INITIAL;
        end
        else if(pc_en) begin //根据信号决定PC的下一个值，异常优先于跳转，优先于普通自增
            if(is_exception) begin
                pc_next <= exception_new_pc;
            end
            else if(is_branch) begin
                pc_next <= branch_address;
            end
            else begin
                pc_next <= pc_reg + 32'd4;
            end
        end
        else begin 
            pc_next <= pc_reg;
        end
    end

    always @(posedge clk) begin
        pc_reg <= pc_next;
    end
	
endmodule
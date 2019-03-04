/*
**  作者：林力韬
**  功能：通用寄存器组
**  照搬清华大学
*/
module regfiles(
	input wire 				clk,		//上升沿驱动
    input wire 				rst,		//低电平复位
	
    input wire 				we,			//1'b 写使能信号，同步写入
    input wire[4:0] 		waddr,
    input wire[31:0] 		wdata,

    input wire[4:0] 		raddr1,
    output reg[31:0] 		rdata1,

    input wire[4:0] 		raddr2,
    output reg[31:0] 		rdata2
);
    
    reg[31:0] registers[0:31];

    always @(posedge clk) begin
        if(!rst) begin //复位所有的寄存器
            registers[0] <= 32'h0;
            registers[1] <= 32'h0;
            registers[2] <= 32'h0;
            registers[3] <= 32'h0;
            registers[4] <= 32'h0;
            registers[5] <= 32'h0;
            registers[6] <= 32'h0;
            registers[7] <= 32'h0;
            registers[8] <= 32'h0;
            registers[9] <= 32'h0;
            registers[10] <= 32'b0;
            registers[11] <= 32'h0;
            registers[12] <= 32'h0;
            registers[13] <= 32'h0;
            registers[14] <= 32'h0;
            registers[15] <= 32'h0;
            registers[16] <= 32'h0;
            registers[17] <= 32'h0;
            registers[18] <= 32'h0;
            registers[19] <= 32'h0;
            registers[20] <= 32'h0;
            registers[21] <= 32'h0;
            registers[22] <= 32'h0;
            registers[23] <= 32'h0;
            registers[24] <= 32'h0;
            registers[25] <= 32'h0;
            registers[26] <= 32'h0;
            registers[27] <= 32'h0;
            registers[28] <= 32'h0;
            registers[29] <= 32'h0;
            registers[30] <= 32'h0;
            registers[31] <= 32'h0;
        end
		
        else if(we && waddr!=5'h0) begin 	//写使能1且写地址非0寄存器，将数据写入reg[waddr] 
            registers[waddr] <= wdata;
        end
    end

    always @(*) begin
        if(raddr1 == 32'h0) 				//读地址为0，直接读常数
            rdata1 <= 32'h0;
        else if(raddr1 == waddr && we) 		//寄存器写入的数据可以立即读出,节省一个周期
            rdata1 <= wdata;
        else
            rdata1 <= registers[raddr1]; 	//读地址1的寄存器值
    end

    always @(*) begin
        if(raddr2 == 32'h0)
            rdata2 <= 32'h0;
        else if(raddr2 == waddr && we)
            rdata2 <= wdata;
        else
            rdata2 <= registers[raddr2]; 	//读地址2的寄存器值
    end

endmodule

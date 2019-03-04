/*
**  作者：林力韬
**  修改：张鑫
**  功能：HILO寄存器
**  原本照搬清华，经过修改后基本上没有参考的部分
*/
module hilo_reg(
	input 					clk,
    input 					resetn,
	
    input 		[1:0]		mode,
    input 		[31:0]		rdata1_wb,
    input 		[31:0]		alu_r1_wb,
    input 		[31:0]		alu_r2_wb,

    output reg	[63:0]		rdata
);
    
    reg[63:0] hilo;

    always @(posedge clk) begin
        if(!resetn) begin
            hilo <= 64'h0;
        end
        else begin
            case(mode) //hilo的三种写入模式，64位全写一般是乘除法指令，高低32位写则分别有对应指令
                2'b11: begin
                    hilo <= { alu_r2_wb,alu_r1_wb };
                end // 2'b00:
                2'b01: begin
                    hilo[31:0] <= rdata1_wb;
                end // 2'b01:
                2'b10: begin
                    hilo[63:32] <= rdata1_wb;
                end // 2'b10:
                default: begin
                    hilo <= hilo;
                end // default:
            endcase // mode
        end
    end

    always @(*) begin
        case(mode) //hilo的三种读出模式，64位全读，读高32位或低32位
            2'b11: begin
                rdata <= { alu_r2_wb,alu_r1_wb };
            end // 2'b00:
            2'b01: begin
                rdata <= { hilo[63:32],rdata1_wb };
            end // 2'b01:
            2'b10: begin
                rdata <= { rdata1_wb,hilo[31:0] };
            end // 2'b10:
            default: begin
                rdata <= hilo;
            end // default:
        endcase // mode
    end // always @(*)

endmodule
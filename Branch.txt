`timescale 1ns / 1ps
//模块功能为将BNE、BEQ、BLEZ、BGTZ、BZ一共6个有跳转跳转控制信号合并成一个branch信号，用于PC_data模块输入
//BZ信号代表BLTZ、BGEZ两条指令，两指令OP相同，均为1，区分为其16至20位不同，BLTZ为0，BGEZ为1
module Branch(Bne,Beq,Blez,Bgtz,Bz,equal,CODE_16,rs_data,Branch_out);
    input Bne,Beq,Blez,Bgtz,Bz,equal,CODE_16;   //equal为ALU的等于输出信号，CODE_16为指令第16位，用于区分BLTZ和BGEZ信号
    input [31:0]rs_data;    //rs寄存器的值
    output Branch_out;  //有条件跳转控制信号
    
    assign Branch_out = (Bne&(~equal)) | (Beq&equal) | (Blez&(rs_data[31]|(rs_data==0)))
                    | (Bgtz&(~rs_data[31])&(rs_data!=0)) | (Bz&(CODE_16&(~rs_data[31]) | ~CODE_16&rs_data[31]));
endmodule

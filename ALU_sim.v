`timescale 1ns / 1ps

module ALU_sim();
    reg [31:0] X, Y;
    reg [3:0] ALU_OP;
    reg [4:0] shamt;
    wire [31:0]Result1, Result2;
    wire OF, UOF, Equal;
    initial begin
        X <= 32'h1249;
        Y <= 32'hFFFFFF0F;
        ALU_OP <= 0;
        shamt <= 2;
    end
    always begin
        #10 ALU_OP = (ALU_OP + 1)%16;
    end
    ALU ALU1 (X, Y, ALU_OP, shamt, Result1, Result2, OF, UOF, Equal);

endmodule

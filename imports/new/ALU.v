`timescale 1ns / 1ps

module ALU(X, Y, ALU_OP, shamt, Result1, Result2, OF, UOF, Equal);
    input [31:0] X, Y;
    input [3:0] ALU_OP;
    input [4:0] shamt;
    output reg [31:0]Result1, Result2;
    output reg OF, UOF;
    output wire Equal;

    assign Equal = (X == Y);

    initial begin
        Result1 = 0;
        Result2 = 0;
        OF = 0;
        UOF = 0;
    end

    always @(X or Y or ALU_OP or shamt)begin
        Result1 = 32'h0000_0000;
        Result2 = 32'h0000_0000;
        OF = 0;
        UOF = 0;
        case(ALU_OP)
        0:begin
            Result1 = Y << shamt;
        end
        1:begin
            Result1 = $signed(Y) >>> shamt;
        end
        2:begin
            Result1 = Y >> shamt;
        end
        3:begin
            {Result2, Result1} = X * Y;
        end
        4:begin
            Result1 = X / Y;
            Result2 = X % Y;
        end
        5:begin
            Result1 = X + Y;
            OF = (X[31] & Y[31] & ~Result1[31]) || (~X[31] & ~Y[31] & Result1[31]);
            UOF = (Result1 < X) || (Result1 < Y);
        end
        6:begin
            Result1 = X - Y;   
            OF = (X[31] & ~Y[31] & ~Result1[31]) || (~X[31] & Y[31] & Result1[31]);
            UOF = Result1 > X;
        end
        7:begin
            Result1 = X & Y;
        end
        8:begin
            Result1 = X | Y;
        end
        9:begin
            Result1 = X ^ Y;
        end
        10:begin
            Result1 = ~(X | Y);
        end
        11:begin
            Result1 = ($signed(X) < $signed(Y)) ? 1 : 0;
        end
        12:begin
            Result1 = (X < Y) ? 1 : 0;
        end
        13:begin
            Result1 = Y;
        end
        default: begin
            Result1 = 32'h0000_0000;
            Result2 = 32'h0000_0000;
        end
        endcase
        if (ALU_OP != 3 && ALU_OP != 4 )begin
            Result2 = 0;
        end
        if (ALU_OP != 5 && ALU_OP != 6 )begin
            UOF = 0;
            OF = 0;
        end
    end
endmodule

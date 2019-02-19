// ROM(32bit)
// input [9:0] Addr, [31:0] Data_input, [1:0] Mode, str (write enable),
// sel (select signal, set to 1 bydefault), clk, clr, ld (write enable, set to 1 by default)
// output Data_output[31:0]

// Definition for signal 'Mode':
//  00  visit by byte 
//  01  visit by half-word
//  10  visit by word
//  11  (reserved) visit by double-word (64-bit)

`timescale 1ns / 1ps
`timescale 1ns / 1ps

module ROM(Addr, Data_input, Mode, str, sel, clk, clr, ld, Data_output);
    parameter ADDR_WIDTH = 5;
    parameter 
        Mode_byte       = 2'b00,
        Mode_halfword   = 2'b01,
        Mode_word       = 2'b10;
        // Mode_doubleword = 2'b11;    // reserved

    input [ADDR_WIDTH-1:0] Addr;
    input [31:0] Data_input;
    input [1:0] Mode;
    input str, sel, clk, clr, ld;
    output reg [31:0] Data_output;
    
    reg [2**(ADDR_WIDTH-2)-1:0] i;
    reg [31:0] mem [2**(ADDR_WIDTH-2)-1:0];
    wire [ADDR_WIDTH-3:0]index;  // have to use this to avoid Synth 8-2898
    
    assign index = Addr[ADDR_WIDTH-1:2];

    initial begin
        $readmemh("D:/rom_data.dat",mem);
    end

    always @(posedge clk or posedge clr)
    begin
        if(clr)begin
            for(i = 0; i <= 2**(ADDR_WIDTH-2)-1; i = i+1) begin
                mem[i] = 32'h0000;
            end 
        end
        else begin
            if(sel) begin
                // select_word = mem[Addr[ADDR_WIDTH-1:2]];

                case(Mode)
                    Mode_byte: begin
                        if (ld) begin   // load byte
                            Data_output[31:8] = 24'h000;
                            case(Addr[1:0])
                                2'b00: begin Data_output[7:0] = mem[index] [7:0];   end
                                2'b01: begin Data_output[7:0] = mem[index] [15:8];  end
                                2'b10: begin Data_output[7:0] = mem[index] [23:16]; end
                                2'b11: begin Data_output[7:0] = mem[index] [31:24]; end
                                default: begin Data_output[7:0] = mem[index] [7:0]; end // TODO
                            endcase

                        end
                        else begin
                            if (str) begin  // store byte
                                case(Addr[1:0])
                                    2'b00: begin mem[index] [7:0] = Data_input[7:0];     end
                                    2'b01: begin mem[index] [15:8] = Data_input[7:0];    end
                                    2'b10: begin mem[index] [23:16] = Data_input[7:0];   end
                                    2'b11: begin mem[index] [31:24] = Data_input[7:0];   end
                                    default: begin mem[index] [7:0] = Data_input[7:0];   end // TODO
                                endcase
                            end
                            else begin
                                // do nothing
                            end
                        end   
                    end

                    Mode_halfword: begin
                        if(ld) begin // load halfword
                            Data_output[31:16] = 16'h00;
                            if(Addr[1:1]) begin // higher part of the word
                                Data_output[15:0] = mem[index] [31:16];
                            end
                            else begin          // lower part of the word
                                Data_output[15:0] = mem[index] [15:0];
                            end
                        end
                        else begin
                            if(str) begin   // store halfword
                                if(Addr[1:1]) begin
                                    mem[index] [31:16] = Data_input[15:0];
                                end
                                else begin
                                    mem[index] [15:0] = Data_input[15:0];
                                end
                            end
                            else begin
                                // do nothing
                            end
                        end
                    end

                    Mode_word: begin
                        if (ld) begin
                            Data_output[31:0] = mem[index];
                        end
                        else begin
                            if (str) begin
                                mem[index] = Data_input;
                            end
                        end                    
                    end

                    // Mode_doubleword: begin
                        
                    // end

                    default: begin
                        // do nothing? TODO
                    end
                endcase
                
            end
            else begin
                // not selected. donothing
            end
        end
    end
endmodule
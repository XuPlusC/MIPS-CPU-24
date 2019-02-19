// ROM(32bit)
// input [9:0] Addr, [31:0] Data_input, [1:0] Mode, str (写使能),
// sel (片选，默认为1), clk, clr, ld (读使能，默认为1)
// output Data_output[31:0]

// Definition for signal 'Mode':
//  00  visit by byte 
//  01  visit by half-word
//  10  visit by word
//  11  (reserved) visit by double-word (64-bit)


`timescale 1ns / 1ps

module ROM(Addr, Data_input, Mode, str, sel, clk, clr, ld, Data_output);
    parameter ADDR_WIDTH = 12;
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
    generate genvar i;

    reg [31:0] mem [2**ADDR_WIDTH-1:0];
    // reg [31:0]select_word;

    initial begin
        $readmemb("rom_data.dat",mem);
    end
    
    always @(clr) begin
        for(i = 0; i <= 99; i = i+1) begin
            mem[i] = 32'h0000;
        end 
    end

    always @(posedge clk)
    begin
        if(sel) begin
            // select_word = mem[Addr[ADDR_WIDTH-1:2]];

            case(Mode)
                Mode_byte: begin
                    if (ld) begin   // load byte
                        Data_output[31:0] = 32'h0000;
                        case(Addr[1:0])
                            2'b00: begin Data_output[7:0] = mem[Addr[ADDR_WIDTH-1:2]] [7:0];   end
                            2'b01: begin Data_output[7:0] = mem[Addr[ADDR_WIDTH-1:2]] [15:8];  end
                            2'b10: begin Data_output[7:0] = mem[Addr[ADDR_WIDTH-1:2]] [23:16]; end
                            2'b11: begin Data_output[7:0] = mem[Addr[ADDR_WIDTH-1:2]] [31:24]; end
                            default: begin Data_output[7:0] = mem[Addr[ADDR_WIDTH-1:2]] [7:0]; end // TODO
                        endcase
                    end
                    else begin
                        if (str) begin  // store byte
                            case(Addr[1:0])
                                2'b00: begin mem[Addr[ADDR_WIDTH-1:2]] [7:0] = Data_input[7:0];     end
                                2'b01: begin mem[Addr[ADDR_WIDTH-1:2]] [15:8] = Data_input[7:0];    end
                                2'b10: begin mem[Addr[ADDR_WIDTH-1:2]] [23:16] = Data_input[7:0];   end
                                2'b11: begin mem[Addr[ADDR_WIDTH-1:2]] [31:24] = Data_input[7:0];   end
                                default: begin mem[Addr[ADDR_WIDTH-1:2]] [7:0] = Data_input[7:0];   end // TODO
                            endcase
                        end
                        else begin
                            // do nothing
                        end
                    end   
                end

                Mode_halfword: begin
                    if(ld) begin // load halfword
                        Data_output[31:0] = 32'h0000;
                        if(Addr[1:1]) begin // higher part of the word
                            Data_output[15:0] = mem[Addr[ADDR_WIDTH-1:2]] [31:16];
                        end
                        else begin          // lower part of the word
                            Data_output[15:0] = mem[Addr[ADDR_WIDTH-1:2]] [15:0];
                        end
                    end
                    else begin
                        if(str) begin   // store halfword
                            if(Addr[1:1]) begin
                                mem[Addr[ADDR_WIDTH-1:2]] [31:16] = Data_input[15:0];
                            end
                            else begin
                                mem[Addr[ADDR_WIDTH-1:2]] [15:0] = Data_input[15:0];
                            end
                        end
                        else begin
                            // do nothing
                        end
                    end
                end

                Mode_word: begin
                    if (ld) begin
                        Data_output[31:0] = mem[Addr[ADDR_WIDTH-1:2]];
                    end
                    else begin
                        if (str) begin
                            mem[Addr[ADDR_WIDTH-1:2]] = Data_input;
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
endmodule
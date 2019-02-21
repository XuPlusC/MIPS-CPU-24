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

// module ROM #(parameter ADDR_WIDTH = 12) (Addr, Data_input, Mode, str, sel, clk, clr, ld, Data_output);
//     parameter 
//         Mode_byte       = 2'b00,
//         Mode_halfword   = 2'b01,
//         Mode_word       = 2'b10;
//         // Mode_doubleword = 2'b11;    // reserved

//     input [ADDR_WIDTH-1:0] Addr;
//     input [31:0] Data_input;
//     input [1:0] Mode;
//     input str, sel, clk, clr, ld;
//     output wire [31:0] Data_output;
    
//     reg [2**(ADDR_WIDTH-2)-1:0] i;
//     reg [31:0] mem [2**(ADDR_WIDTH-2)-1:0];
    
//     wire [31:0] select_word;

//     wire [ADDR_WIDTH-1:0]index;

//     assign index = Addr[ADDR_WIDTH-1:2];
//     assign select_word = (sel == 1)?mem[index]:32'h0000_0000;

//     initial begin
//         for(i = 0; i <= 2**(ADDR_WIDTH-2)-1; i = i+1) begin
//             mem[i] = 32'h0000;
//         end 
//         $readmemh("D:/data_rom.dat",mem);
//     end

//     always @(posedge clk or posedge clr)
//     begin
//         if(clr)begin
//             for(i = 0; i <= 2**(ADDR_WIDTH-2)-1; i = i+1) begin
//                 mem[i] = 32'h0000;
//             end 
//         end
//         else begin
//             if(sel) begin
//                 // select_word = mem[index];
//                 if(str) begin
//                     case(Mode)
//                         Mode_byte: begin
//                             case(Addr[1:0])
//                                     2'b00: begin mem[index] [7:0] = Data_input[7:0];     end
//                                     2'b01: begin mem[index] [15:8] = Data_input[7:0];    end
//                                     2'b10: begin mem[index] [23:16] = Data_input[7:0];   end
//                                     2'b11: begin mem[index] [31:24] = Data_input[7:0];   end
//                                     default: begin mem[index] [7:0] = Data_input[7:0];   end // TODO
//                             endcase
//                         end
//                         Mode_halfword: begin
//                             if(Addr[1:1]) begin
//                                     mem[index] [31:16] = Data_input[15:0];
//                                 end
//                                 else begin
//                                     mem[index] [15:0] = Data_input[15:0];
//                             end
//                         end
//                         Mode_word: begin
//                             mem[index] = Data_input;
//                         end
//                         default: begin
//                             // do nothing
//                         end
//                     endcase
//                 end
//                 else begin
//                     // do nothing
//                 end
//             end
//             else begin
//                 // select_word = 32'h00000000;
//             end
//         end
//     end

//     wire [7:0] mux_out_7_0, mux_out_15_8, mux_out_23_16, mux_out_31_24; 
//     // wire [7:0] mux_in_7_0_0, mux_in_7_0_1, mux_in_7_0_2, mux_in_7_0_3;
//     wire [7:0] mux_in_15_8_0, mux_in_15_8_1, mux_in_15_8_2, mux_in_15_8_3;
//     // wire [7:0] mux_in_23_16_0, mux_in_23_16_1, mux_in_23_16_2, mux_in_23_16_3;
//     // wire [7:0] mux_in_31_24_0, mux_in_31_24_1, mux_in_31_24_2, mux_in_31_24_3;
//     assign mux_out_7_0 = (Mode == Mode_halfword)?((Addr[1] == 1)?select_word[23:16]:select_word[7:0]):
//                             (Mode == Mode_byte)?
//                             (
//                                 (Addr[1:0] == 2'b00)?select_word[7:0]:
//                                 (
//                                     (Addr[1:0] == 2'b01)?select_word[15:8]:
//                                     (
//                                         (Addr[1:0] == 2'b10)?select_word[23:16]:
//                                         (
//                                             select_word[31:24]
//                                         )
//                                     )
//                                 )
//                             ):select_word[7:0];


//     assign mux_in_15_8_0 = 8'b0;
//     assign mux_in_15_8_1 = (Addr[1] == 1)?(select_word[31:24]):(select_word[15:8]);
//     assign mux_in_15_8_2 = select_word[15:8];

//     Mux_2 inst_mux2(mux_in_15_8_0, mux_in_15_8_1, mux_in_15_8_2, 8'b0, Mode, mux_out_15_8);

//     assign mux_out_23_16 = (Mode == Mode_word)?select_word[23:16]:8'b0;
//     assign mux_out_31_24 = (Mode == Mode_word)?select_word[31:24]:8'b0;
//     assign Data_output = {mux_out_31_24, mux_out_23_16, mux_out_15_8, mux_out_7_0};
// endmodule

module ROM #(parameter ADDR_WIDTH = 12) (Addr, Data_input, Mode, str, sel, clk, clr, ld, Data_output);

    input [ADDR_WIDTH-1:0] Addr;
    input [31:0] Data_input;
    input [1:0] Mode;
    input str, sel, clk, clr, ld;
    output wire [31:0] Data_output;
    
    reg [2**(ADDR_WIDTH-2)-1:0] i;
    reg [31:0] mem [2**(ADDR_WIDTH-2)-1:0];

    wire [ADDR_WIDTH-1:0]index;

    assign index = Addr[ADDR_WIDTH-1:2];

    initial begin
        for(i = 0; i <= 2**(ADDR_WIDTH-2)-1; i = i+1) begin
            mem[i] = 32'h0000;
        end 
        $readmemh("D:/data_rom.dat",mem);
    end

    assign Data_output = mem[Addr[ADDR_WIDTH-1:2]];
endmodule
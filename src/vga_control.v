`include "defines.v"

`define GRamZero 15'b000000000000000

module vga_control (
    input wire clk,
    input wire rst,
    input wire[15:0] numbers1_i,
    input wire[15:0] numbers2_i,
    // input wire enable,
    // input wire[15:0] address_in,
    // input wire[15:0] data_in,
    // output reg[15:0] data_out,
    // input wire readWrite_in,
    
    output wire hs,
    output wire vs,
    output wire[2:0] r,
    output wire[2:0] g,
    output wire[2:0] b
);

// reg[255:0] numbers = numbers_i;
// `UNPACK_ARRAY(16, 16, numbers, numbers_i);

reg[13:0] gRamAddr;
reg[31:0] gRamData;

reg[7:0] romAddr;
wire[31:0] romData;
wire[31:0] romDataReverse;

VGACore VGACore0(
    .clk_0(clk),
    .reset(rst),
    .hs(hs),
    .vs(vs),
    .r(r),
    .g(g),
    .b(b),

    .GRamAddra(gRamAddr),
    .GRamDina(gRamData)
);

number_rom number_rom0(
    .clka(clk),
    .addra(romAddr),
    .douta(romDataReverse)
);

integer state;

reg[1:0] io_state;
reg[1:0] INIT = 2'b00, READ = 2'b01, WRITE = 2'b10, HOLD = 2'b11;

// 读取、存放数据
// always @ (posedge clk or negedge rst) begin
//     if (rst == `RstEnable) begin
//         numbers[0] <= `ZeroWord;
//         numbers[1] <= `ZeroWord;
//         numbers[2] <= `ZeroWord;
//         numbers[3] <= `ZeroWord;
//         numbers[4] <= `ZeroWord;
//         numbers[5] <= `ZeroWord;
//         numbers[6] <= `ZeroWord;
//         numbers[7] <= `ZeroWord;
//         numbers[8] <= `ZeroWord;
//         numbers[9] <= `ZeroWord;
//         numbers[10] <= `ZeroWord;
//         numbers[11] <= `ZeroWord;
//         numbers[12] <= `ZeroWord;
//         numbers[13] <= `ZeroWord;
//         numbers[14] <= `ZeroWord;
//         numbers[15] <= `ZeroWord;
//         io_state <= INIT;
//     end else begin
//         case (io_state)
//             INIT: begin
//                 if (readWrite_in == `MemRead) begin
//                     io_state <= READ;
//                 end else begin
//                     io_state <= WRITE;
//                 end
//             end
//             READ: begin
//                 data_out <= numbers[address_in[3:0]];
//                 io_state <= HOLD;
//             end
//             WRITE: begin
//                 numbers[address_in[3:0]] <= data_in;
//                 io_state <= HOLD;
//             end
//             HOLD: begin
//                 io_state <= INIT;
//             end
//             default: io_state <= INIT;
//         endcase
//     end
// end

integer line_state, vga_state;
integer ROW_OFFSET = 100, COLUMN_OFFSET = 192;
integer VGA_INIT = 0, WRITE_GRAM = 1, VGA_HOLD = 2;
integer GRAM_ROW_DIFF = 20;
integer GRAM_LINE_BASE = 40 * 20;
integer GRAM_ROW_PADDING = 32;
integer GRAM_COLUMN_PADDING = 2;
integer GRAM_ROW_OFFSET = 40;
integer GRAM_COLUMN_OFFSET = 6;
integer number_index, column_index, row_index;
integer romBaseAddr;

// 画缓存
always @ (posedge clk or negedge rst) begin
    if (rst == `RstEnable) begin
        number_index <= 0;
        column_index <= 0;
        row_index <= 0;
        line_state <= 0;
        vga_state <= 0;
        romBaseAddr <= 0;
    end else begin
        case (vga_state)
            VGA_INIT: begin
                romAddr <= romBaseAddr * 16 + line_state;
                gRamAddr <= GRAM_ROW_OFFSET * GRAM_ROW_DIFF + GRAM_COLUMN_OFFSET
                        + GRAM_COLUMN_PADDING * column_index
                        + line_state * GRAM_ROW_DIFF
                        + GRAM_ROW_PADDING * GRAM_ROW_DIFF * row_index;
                vga_state <= WRITE_GRAM;
            end
            WRITE_GRAM: begin
                gRamData <= romData;
                vga_state <= VGA_HOLD;
            end
            VGA_HOLD: begin
                if (line_state == 15) begin
                    line_state <= 0;
                    if (column_index == 3) begin
                        column_index <= 0;
                        if (row_index == 3) begin
                            row_index <= 0;
                        end else begin
                            row_index <= row_index + 1;
                        end
                    end else begin
                        column_index <= column_index + 1;
                    end
                end else begin
                    line_state <= line_state + 1;
                end
                // case (numbers[row_index * 4 + column_index])
                //     0: romBaseAddr <= 1;    // TODO: this should be zero
                //     1: romBaseAddr <= 1;
                //     2: romBaseAddr <= 2;
                //     3: romBaseAddr <= 3;
                //     4: romBaseAddr <= 4;
                //     5: romBaseAddr <= 5;
                //     6: romBaseAddr <= 6;
                //     7: romBaseAddr <= 7;
                //     8: romBaseAddr <= 8;
                //     9: romBaseAddr <= 9;
                //     10: romBaseAddr <= 10;
                //     12: romBaseAddr <= 11;
                //     default: romBaseAddr <= 0;
                // endcase
                // case (row_index * 4 + column_index)
                //     0: romBaseAddr <= numbers_i[15:0];
                //     1: romBaseAddr <= numbers_i[31:16];
                //     2: romBaseAddr <= numbers_i[47:32];
                //     3: romBaseAddr <= numbers_i[63:48];
                //     4: romBaseAddr <= numbers_i[79:64];
                //     5: romBaseAddr <= numbers_i[95:80];
                //     6: romBaseAddr <= numbers_i[111:96];
                //     7: romBaseAddr <= numbers_i[127:112];
                //     8: romBaseAddr <= numbers_i[143:128];
                //     9: romBaseAddr <= numbers_i[159:144];
                //     10: romBaseAddr <= numbers_i[175:160];
                //     11: romBaseAddr <= numbers_i[191:176];
                //     12: romBaseAddr <= numbers_i[207:192];
                //     13: romBaseAddr <= numbers_i[223:208];
                //     14: romBaseAddr <= numbers_i[239:224];
                //     15: romBaseAddr <= numbers_i[255:240];
                // endcase
                case (row_index * 4 + column_index)
                    0: romBaseAddr <= numbers1_i;
                    1: romBaseAddr <= numbers2_i;
                    default:
                
                // romBaseAddr <= numbers_i[(row_index * 4 + column_index)*16+15:(row_index * 4 + column_index)*16];
                vga_state <= VGA_INIT;
            end
            default: ;
        endcase
    end
end

assign romData[0] = romDataReverse[31];
assign romData[1] = romDataReverse[30];
assign romData[2] = romDataReverse[29];
assign romData[3] = romDataReverse[28];
assign romData[4] = romDataReverse[27];
assign romData[5] = romDataReverse[26];
assign romData[6] = romDataReverse[25];
assign romData[7] = romDataReverse[24];
assign romData[8] = romDataReverse[23];
assign romData[9] = romDataReverse[22];
assign romData[10] =romDataReverse[21];
assign romData[11] = romDataReverse[20];
assign romData[12] = romDataReverse[19];
assign romData[13] = romDataReverse[18];
assign romData[14] = romDataReverse[17];
assign romData[15] = romDataReverse[16];
assign romData[16] = romDataReverse[15];
assign romData[17] = romDataReverse[14];
assign romData[18] = romDataReverse[13];
assign romData[19] = romDataReverse[12];
assign romData[20] = romDataReverse[11];
assign romData[21] = romDataReverse[10];
assign romData[22] = romDataReverse[9];
assign romData[23] = romDataReverse[8];
assign romData[24] = romDataReverse[7];
assign romData[25] = romDataReverse[6];
assign romData[26] = romDataReverse[5];
assign romData[27] = romDataReverse[4];
assign romData[28] = romDataReverse[3];
assign romData[29] = romDataReverse[2];
assign romData[30] = romDataReverse[1];
assign romData[31] = romDataReverse[0];




endmodule // char_map

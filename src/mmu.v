`include "defines.v"

module mmu (
    // 与上层的接口
    input wire[`MemAddrBus] memAddress_i,   // 仿存地址
    input wire[`MemBus] memDataWrite_i, // 写入数据
    input wire memReadWrite_i,  // 读或写
    input wire memEnable_i, // 使能
    output reg[`MemBus] memDataRead_o,   // 读到的数据

    // 与下层的接口
    // RAM
    output reg ram_enable_o,
    output reg ram_readWrite_o,
    output reg[`MemAddrBus] ram_address_o,
    output reg[`MemBus] ram_dataWrite_o,
    input wire[`MemBus] ram_dataRead_i,

    // 串口
    output reg[`HalfWordBus] serial_dataWrite_o,
    output reg serial_readWrite_o, //en1
    output reg serial_enable_o, //en2
    output reg serial_fetch_data_o, //en3
    input wire[`HalfWordBus] serial_dataRead_i,
    input wire serial_sendComplete_i,
    input wire serial_receiveComplete_i,

    // VGA
    // output reg vga_enable_o,
    // output reg[15:0] vga_address_o,
    // output reg[15:0] vga_dataWrite_o,
    // input wire[15:0] vga_dataRead_i,
    // output reg vga_readWrite_o
    // output reg vga_enable_o,
    // output reg[10:0] vga_address_o,
    // output reg[7:0] vga_dataWrite_o
    output reg[15:0] numbers1_o,
    output reg[15:0] numbers2_o,

    //KB
    output reg kb_data_receive,
    input wire kb_data_ready,
    input wire[7:0] kb_ascii
);

// `PACK_ARRAY(16, 16, numbers, numbers_o);
// always @(*) begin
//     numbers_o = numbers;
// end
integer cnt;

always @ ( * ) begin
    // $display("%b", serial_dataWrite_o);
    serial_enable_o = `Enable;
    serial_readWrite_o = 0; //平常为读状态
    serial_fetch_data_o = 0;
    kb_data_receive = 1;
    if (memAddress_i == `SerialIOAddr) begin
        ram_enable_o = `Disable;
        serial_readWrite_o = memReadWrite_i;
        if (memReadWrite_i == `MemWrite) begin   // 写
            serial_dataWrite_o = memDataWrite_i[7:0];
        end else begin                          // 读
            serial_fetch_data_o = 1;
            // memDataRead_o = 16'h0041;
            memDataRead_o = {8'h00, serial_dataRead_i};
        end
    end else if (memAddress_i == `SerialStatusAddr) begin
        ram_enable_o = `Disable;
        if (memReadWrite_i == `MemRead) begin  // 测试读写状态
            // memDataRead_o = 16'hffff;
            memDataRead_o = {14'b0, serial_receiveComplete_i, serial_sendComplete_i};
        end
    end else if (memAddress_i[15:8] == 8'hBE) begin
        // vga_enable_o = `Enable;
        // vga_readWrite_o = memReadWrite_i;
        // numbers_o[47:32] = 16'h0001;
        if (memReadWrite_i == `MemWrite) begin
            case (memAddress_i[3:0])
                0: numbers1_o = memDataWrite_i;
                1: numbers2_o = memDataWrite_i;
                default: number
            endcase
            // if (memAddress_i[3:0] == 4'hF) begin
            //     numbers[255:240] = memDataWrite_i;
            // end
            // numbers_o[memAddress_i ]
            // case (memAddress_i[3:0])
            //     0: numbers[15:0] = memDataWrite_i;
            //     1: numbers[31:16] = memDataWrite_i;
            //     2: numbers[47:32] = memDataWrite_i;
            //     3: numbers[63:48] = memDataWrite_i;
            //     4: numbers[79:64] = memDataWrite_i;
            //     5: numbers[95:80] = memDataWrite_i;
            //     6: numbers[111:96] = memDataWrite_i;
            //     7: numbers[127:112] = memDataWrite_i;
            //     8: numbers[143:128] = memDataWrite_i;
            //     9: numbers[159:144] = memDataWrite_i;
            //     10: numbers[175:160] = memDataWrite_i;
            //     11: numbers[191:176] = memDataWrite_i;
            //     12: numbers[207:192] = memDataWrite_i;
            //     13: numbers[223:208] = memDataWrite_i;
            //     14: numbers[239:224] = memDataWrite_i;
            //     15: numbers[255:240] = memDataWrite_i;
            //     // default:
            // endcase
        end else begin
            case (memAddress_i[3:0])
                0: memDataRead_o = numbers1_o;
                1: memDataRead_o = numbers2_o;
                default: begin end
            endcase
            // case (memAddress_i[3:0])
            //     0: memDataRead_o = numbers[15:0];
            //     1: memDataRead_o = numbers[31:16];
            //     2: memDataRead_o = numbers[47:32];
            //     3: memDataRead_o = numbers[63:48];
            //     4: memDataRead_o = numbers[79:64];
            //     5: memDataRead_o = numbers[95:80];
            //     6: memDataRead_o = numbers[111:96];
            //     7: memDataRead_o = numbers[127:112];
            //     8: memDataRead_o = numbers[143:128];
            //     9: memDataRead_o = numbers[159:144];
            //     10: memDataRead_o = numbers[175:160];
            //     11: memDataRead_o = numbers[191:176];
            //     12: memDataRead_o = numbers[207:192];
            //     13: memDataRead_o = numbers[223:208];
            //     14: memDataRead_o = numbers[239:224];
            //     15: memDataRead_o = numbers[255:240];
            //     // default:
            // endcase
            // memDataRead_o = numbers[memAddress_i[3:0]*16+15:memAddress_i[3:0]*16];
            // vga_address_o = memAddress_i;
            // memDataRead_o = vga_dataRead_i;
        end
    end else if (memAddress_i == `KeyboardIOAddr) begin
        if (memReadWrite_i == `MemRead) begin // 读
            kb_data_receive = 0;
            memDataRead_o = {8'h00, kb_ascii};
        end
    end else if (memAddress_i == `KeyboardStatusAddr) begin
        if (memReadWrite_i == `MemRead) begin  // 测试读写状态
            memDataRead_o = {15'b0, kb_data_ready};
        end   
    end else if(memAddress_i == 16'hBF04) begin //随机数生成器
        cnt = cnt + 1;
        if (cnt >= 32) begin
            cnt = 0;
        end
        if (memReadWrite_i == `MemWrite) begin
            ram_dataWrite_o = cnt;
        end
    end else begin
        ram_enable_o = `Enable;
        ram_readWrite_o = memReadWrite_i;
        ram_address_o = memAddress_i;
        if (memReadWrite_i == `MemWrite) begin   // 写
            ram_dataWrite_o = memDataWrite_i;
        end else begin                          // 读
            ram_dataWrite_o = `ZeroWord;
            memDataRead_o = ram_dataRead_i;
        end
    end
end

endmodule // mmu

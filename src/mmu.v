`include "defines.v"

module mmu (
    input wire clk,

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
    // output reg vga_readWrite_o,
    output wire[15:0] number0_o ,
    output wire[15:0] number1_o ,
    output wire[15:0] number2_o ,
    output wire[15:0] number3_o ,
    output wire[15:0] number4_o ,
    output wire[15:0] number5_o ,
    output wire[15:0] number6_o ,
    output wire[15:0] number7_o ,
    output wire[15:0] number8_o ,
    output wire[15:0] number9_o ,
    output wire[15:0] number10_o,
    output wire[15:0] number11_o,
    output wire[15:0] number12_o,
    output wire[15:0] number13_o,
    output wire[15:0] number14_o,
    output wire[15:0] number15_o,

    //KB
    output reg kb_data_receive,
    input wire kb_data_ready,
    input wire[7:0] kb_ascii


    // output reg vga_enable_o,
    // output reg[10:0] vga_address_o,
    // output reg[7:0] vga_dataWrite_o
);

integer cnt;

reg[15:0] number0;
reg[15:0] number1;
reg[15:0] number2;
reg[15:0] number3;
reg[15:0] number4;
reg[15:0] number5;
reg[15:0] number6;
reg[15:0] number7;
reg[15:0] number8;
reg[15:0] number9;
reg[15:0] number10;
reg[15:0] number11;
reg[15:0] number12;
reg[15:0] number13;
reg[15:0] number14;
reg[15:0] number15;

assign number0_o = number0;
assign number1_o = number1;
assign number2_o = number2;
assign number3_o = number3;
assign number4_o = number4;
assign number5_o = number5;
assign number6_o = number6;
assign number7_o = number7;
assign number8_o = number8;
assign number9_o = number9;
assign number10_o =number10;
assign number11_o =number11;
assign number12_o =number12;
assign number13_o =number13;
assign number14_o =number14;
assign number15_o =number15;

always @ ( negedge clk ) begin
    cnt = cnt + 1;
    if (memAddress_i >= 16'hBE00 && memAddress_i <= 16'hBE0F) begin
        if (memReadWrite_i == `MemWrite) begin
            if (memAddress_i[3:0] == 4'h0) begin
                number0 <= memDataWrite_i;
            end
            else if (memAddress_i[3:0] == 4'h1) begin
                number1 <= memDataWrite_i;
            end
            else if (memAddress_i[3:0] == 4'h2) begin
                number2 <= memDataWrite_i;
            end
            else if (memAddress_i[3:0] == 4'h3) begin
                number3 <= memDataWrite_i;
            end
            else if (memAddress_i[3:0] == 4'h4) begin
                number4 <= memDataWrite_i;
            end
            else if (memAddress_i[3:0] == 4'h5) begin
                number5 <= memDataWrite_i;
            end
            else if (memAddress_i[3:0] == 4'h6) begin
                number6 <= memDataWrite_i;
            end
            else if (memAddress_i[3:0] == 4'h7) begin
                number7 <= memDataWrite_i;
            end
            else if (memAddress_i[3:0] == 4'h8) begin
                number8 <= memDataWrite_i;
            end
            else if (memAddress_i[3:0] == 4'h9) begin
                number9 <= memDataWrite_i;
            end
            else if (memAddress_i[3:0] == 4'hA) begin
                number10 <= memDataWrite_i;
            end
            else if (memAddress_i[3:0] == 4'hB) begin
                number11 <= memDataWrite_i;
            end
            else if (memAddress_i[3:0] == 4'hC) begin
                number12 <= memDataWrite_i;
            end
            else if (memAddress_i[3:0] == 4'hD) begin
                number13 <= memDataWrite_i;
            end
            else if (memAddress_i[3:0] == 4'hE) begin
                number14 <= memDataWrite_i;
            end
            else if (memAddress_i[3:0] == 4'hF) begin
                number15 <= memDataWrite_i;
            end else begin end
        end
    end
end

always @(negedge clk) begin
    if (memAddress_i == `KeyboardIOAddr) begin
        if (memReadWrite_i == `MemRead) begin // 读
            kb_data_receive = 0;
            // memDataRead_o = {8'h00, kb_ascii};
        end
    end else begin
        kb_data_receive = 1;
    end
end

always @ ( memAddress_i or memReadWrite_i ) begin
    // $display("%b", serial_dataWrite_o);
    serial_enable_o = `Enable;
    serial_readWrite_o = 0; //平常为读状态
    serial_fetch_data_o = 0;
    // kb_data_receive = 1;
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
    end else if (memAddress_i == `KeyboardIOAddr) begin
        if (memReadWrite_i == `MemRead) begin // 读
            // kb_data_receive = 0;
            memDataRead_o = {8'h00, kb_ascii};
        end
    end else if (memAddress_i == `KeyboardStatusAddr) begin
        if (memReadWrite_i == `MemRead) begin  // 测试读写状态
            memDataRead_o = {15'b0, kb_data_ready};
        end   
    end else if(memAddress_i == `RandomIOAddr) begin //随机数生成器
        // cnt = cnt + 1;
        // if (cnt >= 32) begin
        //     cnt = 0;
        // end
        if (memReadWrite_i == `MemRead) begin
            memDataRead_o = cnt;
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

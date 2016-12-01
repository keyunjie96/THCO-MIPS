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
    output reg[`MemBus] serial_dataWrite_o,
    output reg serial_readWrite_o, //en1
    output reg serial_enable_o, //en2
    output reg serial_fetch_data_o, //en3
    input wire[`MemBus] serial_dataRead_i,
    input wire serial_sendComplete_i,
    input wire serial_receiveComplete_i
);

always @ ( * ) begin
    // $display("%b", serial_dataWrite_o);
    serial_enable_o = `Enable;
    serial_readWrite_o = 0; //平常为读状态
    serial_fetch_data_o = 0;
    if (memAddress_i == `SerialIOAddr) begin
        ram_enable_o = `Disable;
        serial_readWrite_o = memReadWrite_i;
        if (memReadWrite_i == `MemWrite) begin   // 写
            serial_dataWrite_o = memDataWrite_i;
        end else begin                          // 读
            serial_fetch_data_o = 1;
            // memDataRead_o = 16'h0041;
            memDataRead_o = serial_dataRead_i;
        end
    end else if (memAddress_i == `SerialStatusAddr) begin
        ram_enable_o = `Disable;
        if (memReadWrite_i == `MemRead) begin  // 测试读写状态
            // memDataRead_o = 16'hffff;
            memDataRead_o = {14'b0, serial_receiveComplete_i, serial_sendComplete_i};
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

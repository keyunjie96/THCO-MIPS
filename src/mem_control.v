`include "defines.v"

module mem_control (
    // 与上层的接口
    input wire[`InstAddrBus]    instAddress_i,      // IF段取址地址
    output reg[`InstBus]        instData_o,         // 给IF/ID的指令

    input wire[`MemAddrBus]     memAddress_i,       // MEM段数据地址
    input wire[`MemBus]         memDataWrite_i,     // MEM段数据
    input wire                  memWriteEnable_i,   // MEM写使能
    input wire                  memReadEnable_i,    // MEM读使能
    input wire                  pauseRequest_i,     // 暂停流水线信号
    output reg[`MemBus]         memDataRead_o,      // 给MEM的数据


    // 与下层的接口
    input wire[`MemBus]         memDataRead_i,      // 从下层读到的数据
    output reg[`MemAddrBus]     memAddress_o,       // 给下层的仿存地址
    output reg[`MemBus]         memDataWrite_o,     // 写给下层的数据
    output reg                  memReadWrite_o,     // 读或写
    output reg                  memEnable_o         // 仿存使能信号
);

always @ ( * ) begin
    if (pauseRequest_i == `Disable) begin
        memAddress_o = instAddress_i;
        memReadWrite_o = `MemRead;
        memEnable_o = `Enable;
        instData_o = memDataRead_i;
    end else begin
        memAddress_o = memAddress_i;
        if (memReadEnable_i == `Enable && memWriteEnable_i == `Disable) begin
            memReadWrite_o = `MemRead;
            memEnable_o = `Enable;
        end else if (memReadEnable_i == `Disable && memWriteEnable_i == `Enable) begin
            memReadWrite_o = `MemWrite;
            memDataWrite_o = memDataWrite_i;
            memEnable_o = `Enable;
        end else begin
            memEnable_o = `Disable;
        end
        memDataRead_o = memDataRead_i;
    end
end

endmodule // mem_control

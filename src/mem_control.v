`include "defines.v"

module mem_control (
    // 时钟
    input wire clk,
    input wire rst,

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

`define S_IDLE 2'b00
`define S_INST 2'b01
`define S_DATA 2'b10

reg[1:0] state = `S_IDLE;   // 状态
reg[1:0] preserve_state;
reg[`InstBus] dataBuffer;   // 缓存的数据

// 状态机状态转移
always @ (posedge clk or negedge rst) begin
    if (rst == `RstDisable) begin
        state <= `S_IDLE;
    end else begin
        case (state)
            `S_IDLE: begin
                memEnable_o <= `Disable;
                preserve_state <= `S_INST;
                state <= `S_INST;
            end
            `S_INST: begin
                // 下层
                memEnable_o <= `Enable;
                memAddress_o <= instAddress_i;
                memReadWrite_o <= `MemRead;
                preserve_state <= state;
                if (pauseRequest_i == `Disable)
                    state <= `S_INST;
                else
                    state <= `S_DATA;
            end
            `S_DATA: begin
                // 下层
                memEnable_o <= `Enable;
                memAddress_o <= memAddress_i;
                if (memReadEnable_i == 1 && memWriteEnable_i == 0) begin  // 读
                    memReadWrite_o <= `MemRead;
                end else if (memReadEnable_i == 0 && memWriteEnable_i == 1) begin  // 写
                    memReadWrite_o <= `MemWrite;
                    memDataWrite_o <= memDataWrite_i;
                end else begin
                    memEnable_o <= `Disable;
                end
                preserve_state <= state;
                state <= `S_INST;
            end
            default: state <= `S_IDLE;
        endcase
    end
end

// 处理向上层的输出
always @ ( memDataRead_i ) begin
    case (preserve_state)
        `S_IDLE: begin
            instData_o = `ZeroWord;     // TODO: 改成NOP应该更好
            memDataRead_o = `ZeroWord;
        end
        `S_INST: begin
            dataBuffer = memDataRead_i;
            instData_o = memDataRead_i;
        end
        `S_DATA: begin
            instData_o = dataBuffer;
            memDataRead_o = memDataRead_i;
        end
        default: ;
    endcase
end

endmodule // mem_control

`include "defines.v"

module mem_bridge (
    // 输入时钟和重置信号
    input wire clk,
    input wire rst,
    input wire[15:0] sw,

    // 输出的时钟
    output reg clk_full,
    output reg clk_quarter,

    // 与CPU的接口
    // 连接PC
    input wire[`InstAddrBus]    instAddress_i,      // IF段取址地址
    output reg[`InstBus]        instData_o,         // 给IF/ID的指令

    // 连接MEM
    input wire[`MemAddrBus]     memAddress_i,       // MEM段数据地址
    input wire[`MemBus]         memDataWrite_i,     // MEM段数据
    input wire                  memWriteEnable_i,   // MEM写使能
    input wire                  memReadEnable_i,    // MEM读使能
    input wire                  pauseRequest_i,     // 暂停流水线信号
    output reg[`MemBus]         memDataRead_o,      // 给MEM的数据

    // 与MMU的接口
    input wire[`MemBus]         memDataRead_i,      // 从下层读到的数据
    output reg[`MemAddrBus]     memAddress_o,       // 给下层的仿存地址
    output reg[`MemBus]         memDataWrite_o,     // 写给下层的数据
    output reg                  memReadWrite_o,     // 读或写
    output reg                  memEnable_o,        // 仿存使能信号

    // 与Flash控制器的接口
    output reg[22:1]            flashAddr_o,
    output wire                  flashCtl_o,
    input wire[`MemBus]         flashDataRead_i,

    // 与RAM控制器的接口
    output reg[1:0]             ramState_o
);

reg[3:0] state;
reg[3:0] BOOT = 4'h0, BOOT_START = 4'h1, BOOT_FLASH = 4'h2, BOOT_RAM = 4'h3,
            BOOT_COMPLETE = 4'h4, RUN1 = 4'h5, RUN2 = 4'h6, RUN3 = 4'h7,
            RUN4 = 4'h8;
reg[3:0] flashTimer;
reg[22:1] flashBootAddr;
reg[`MemBus] flashBootData;
reg[22:1] FlashAddrZero = 22'b0000000000000000000000;
reg[1:0] ramState;
reg[1:0] ONE = 2'b00, TWO = 2'b01, THREE = 2'b11, FOUR = 2'b10;

assign flashCtl_o = state == BOOT_FLASH ? 0 : 1;

// 同步的全频率时钟
always @ ( clk ) begin
    if (rst == `RstEnable) begin
        clk_full <= 0;
    end else begin
        clk_full <= clk;
    end
end


// 拨码开关最高位置1时开始boot
always @ (posedge clk or negedge rst) begin
    if (rst == `RstEnable) begin
        clk_quarter <= 0;
        state <= sw[15] == 1 ? BOOT_START : BOOT;
    end else begin
        case (state)
            BOOT: begin
                state <= BOOT;
            end
            BOOT_START: begin
                flashTimer <= 4'h0;               // flash时钟较慢
                flashBootAddr <= FlashAddrZero;
                // flashCtl_o <= 0;
                state <= BOOT_FLASH;
            end
            BOOT_FLASH: begin
                if (flashTimer == 4'h0) begin
                    // 给出地址和控制信号
                    flashAddr_o <= flashBootAddr;
                    // flashCtl_o <= ~flashCtl_o;      // 控制信号取反
                    flashTimer <= flashTimer + 1;
                    state <= BOOT_FLASH;
                end else if (flashTimer == 4'hF) begin
                    // 第16个时钟周期取出数据，转入写内存状态
                    flashBootData <= flashDataRead_i;
                    flashTimer <= 4'h0;
                    // ramState应当转入1（准备信号）
                    ramState <= ONE;
                    ramState_o <= ONE;
                    state <= BOOT_RAM;
                end else begin
                    // 等待取出数据
                    flashTimer <= flashTimer + 1;
                    state <= BOOT_FLASH;
                end
            end
            BOOT_RAM: begin
                case (ramState)
                    ONE: begin
                        // ram在下一周期进入VISIT，应当给出地址和数据
                        // 这一部分在组合逻辑中给出
                        ramState <= TWO;
                        ramState_o <= TWO;
                        state <= BOOT_RAM;
                    end
                    TWO: begin
                        // ram在下一周期改变控制信号，地址和数据保持
                        ramState <= THREE;
                        ramState_o <= THREE;
                        state <= BOOT_RAM;
                    end
                    THREE: begin
                        // 再给一个周期写
                        ramState <= FOUR;
                        ramState_o <= FOUR;
                        state <= BOOT_RAM;
                    end
                    FOUR: begin
                        // 下一个周期视当前地址，读flash或完成boot
                        flashBootAddr <= flashBootAddr + 1;
                        // 监控存在0-3FFF
                        if (flashBootAddr > 16'h3FFF) begin
                            state <= BOOT_COMPLETE;
                        end else begin
                            state <= BOOT_FLASH;
                        end
                    end
                    default: state <= BOOT;
                endcase
            end
            BOOT_COMPLETE: begin
                // CPU准备开始工作
                ramState <= ONE;
                ramState_o <= ONE;
                state <= RUN1;
                // state <= BOOT;
            end
            RUN1: begin
                clk_quarter <= 1;
                ramState <= TWO;
                ramState_o <= TWO;
                state <= RUN2;
            end
            RUN2: begin
                clk_quarter <= 1;
                ramState <= THREE;
                ramState_o <= THREE;
                state <= RUN3;
            end
            RUN3: begin
                clk_quarter <= 0;
                ramState <= FOUR;
                ramState_o <= FOUR;
                state <= RUN4;
            end
            RUN4: begin
                clk_quarter <= 0;
                ramState <= ONE;
                ramState_o <= ONE;
                state <= RUN1;
            end
            default: state <= BOOT;
        endcase
    end
end

// 组合逻辑部分，在boot时送往MMU的数据应当来自flash，而运行CPU时应当来自CPU
always @ ( * ) begin
    if (state == BOOT_RAM) begin
        memAddress_o = flashBootAddr[16:1];
        memDataWrite_o = flashBootData;
        memEnable_o = `Enable;
        memReadWrite_o = `MemWrite;
    end else begin
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
end

endmodule   // mem_bridge

`include "defines.v"

module ex_mem (
  // input
  input wire                clk,
  input wire                rst,
  input wire[`StallRegBus]  stall,
  // MEM
  input wire[`MemAddrBus]    memAddr_i,       // 内存地址
  input wire                 rMem_i,          // 是否读取内存
  input wire                 wMem_i,          // 是否写入内存 
  // MEM-WB
  input wire[`RegBus]       wData_i,
  // WB
  input wire wReg_i,
  input wire[`RegAddrBus]   wRegAddr_i,

  // output
  // MEM
  output reg[`MemAddrBus]     memAddr_o,       // 内存地址
  output reg                  rMem_o,          // 是否读取内存
  output reg                  wMem_o,          // 是否写入内存 
  // MEM-WB
  output reg[`RegBus]       wData_o,
  // WB
  output reg                wReg_o,
  output reg[`RegAddrBus]   wRegAddr_o
);

always @ (posedge clk) begin
  if ((rst == `RstEnable) || ((stall[3] == `Stop) & (stall[4] == `NoStop))) begin
    // MEM
    memAddr_o <= `ZeroWord;
    rMem_o <= `Disable;
    wMem_o <= `Disable;
    // MEM-WB
    wData_o <= `ZeroWord;
    // WB
    wReg_o <= `Disable;
    wRegAddr_o <= `RegZero;
  end
  else if(stall[3] == `NoStop) begin
    memAddr_o <= memAddr_i;
    rMem_o <= rMem_i;
    wMem_o <= wMem_i;
    wData_o <= wData_i;
    wRegAddr_o <= wRegAddr_i;
    wReg_o <= wReg_i;
  end
end

endmodule // ex_mem

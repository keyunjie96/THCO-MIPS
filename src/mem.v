`include "defines.v"

module mem (
  // input
  // MEM
  input wire[`MemAddrBus]   memAddr_i,       // 内存地址
  input wire                rMem_i,          // 是否读取内存
  input wire                wMem_i,          // 是否写入内存
  // MEM-WB
  input wire[`RegBus]       wData_i,
  // WB
  input wire                wReg_i,
  input wire[`RegAddrBus]   wRegAddr_i,
  // output
  // mem_control
  input wire[`MemBus]       wData_mem_i,
  output reg[`MemAddrBus]   memAddr_o,
  output reg[`MemBus]       wData_mem_o,
  output reg                rMem_o,
  output reg                wMem_o,

  // WB
  output reg[`RegBus]       wData_o,
  output reg                wReg_o,
  output reg[`RegAddrBus]   wRegAddr_o,
  //控制流水线暂停
  output reg                stall_request
);

// 访存
always @ ( * ) begin
  memAddr_o <= memAddr_i;
  if (rMem_i == `ReadEnable) begin
    wData_o <= wData_mem_i;
  end else if (wMem_i == `WriteEnable) begin
    wData_mem_o <= wData_i;
  end else begin
    wData_o <= wData_i;
  end
end

// 传递控制信号和数据
always @ ( * ) begin
  // mem_control
  rMem_o <= rMem_i;
  wMem_o <= wMem_i;
  stall_request <= wMem_i | rMem_i; //需要写入时，停止流水线
  wReg_o <= wReg_i;
  wRegAddr_o <= wRegAddr_i;
end

endmodule // mem

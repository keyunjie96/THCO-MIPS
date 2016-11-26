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
  // WB
  output reg[`RegBus]       wData_o,
  output reg                wReg_o,
  output reg[`RegAddrBus]   wRegAddr_o,
  //控制流水线暂停
  output reg                  stall_request
);

// 访存
always @ ( * ) begin
  wData_o <= wData_i;
end

// 传递控制信号和数据
always @ ( * ) begin
  stall_request <= wMem_i; //需要写入时，停止流水线
  wReg_o <= wReg_i;
  wRegAddr_o <= wRegAddr_i;
end

endmodule // mem

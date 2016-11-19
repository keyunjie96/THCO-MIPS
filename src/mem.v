`include "defines.v"

module mem (
  // input
  // WB-MEM
  input wire[`RegBus]       wData_i,
  // WB
  input wire                wReg_i,
  input wire[`RegAddrBus]   wRegAddr_i,
  // output
  // WB
  output reg[`RegBus]       wData_o,
  output reg                wReg_o,
  output reg[`RegAddrBus]   wRegAddr_o
);

// 访存
always @ ( * ) begin
  wData_o = wData_i;
end

// 传递控制信号和数据
always @ ( * ) begin
  wReg_o = wReg_i;
  wRegAddr_o = wRegAddr_i;
end

endmodule // mem

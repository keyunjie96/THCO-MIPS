`include "defines.v"

module mem_wb (
  // input
  input wire                clk,
  input wire                rst,
  input wire[`StallRegBus]  stall,
  // WB
  input wire[`RegBus]       wData_i,
  input wire                wReg_i,
  input wire[`RegAddrBus]   wRegAddr_i,

  // ouput
  // WB
  output reg[`RegBus]       wData_o,
  output reg                wReg_o,
  output reg[`RegAddrBus]   wRegAddr_o
);

always @ (posedge clk) begin
  if ((rst == `RstEnable) || ((stall[4] == `Stop) & (stall[5] == `NoStop))) begin
    wData_o <= `ZeroWord;
    wReg_o <= `Disable;
    wRegAddr_o <= `DisableRegAddr;
  end
  else if (stall[4] == `NoStop) begin
    wData_o <= wData_i;
    wReg_o <= wReg_i;
    wRegAddr_o <= wRegAddr_i;
  end
end

endmodule // mem_wb

`include "defines.v"

module ex_mem (
  // input
  input wire                clk,
  input wire                rst,
  // MEM-WB
  input wire[`RegBus]       wData_i,
  // WB
  input wire wReg_i,
  input wire[`RegAddrBus]   wRegAddr_i,

  // output
  // MEM-WB
  output reg[`RegBus]       wData_o,
  // WB
  output reg                wReg_o,
  output reg[`RegAddrBus]   wRegAddr_o
);

always @ (posedge clk) begin
  if (rst == `RstEnable) begin
    wData_o <= `ZeroWord;
    wReg_o <= `Disable;
    wRegAddr_o <= `RegZero;
  end
  else begin
    wData_o <= wData_i;
    wRegAddr_o <= wRegAddr_i;
    wReg_o <= wReg_i;
  end
end

endmodule // ex_mem

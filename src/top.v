`include "defines.v"

module top (
  input wire clk,
  input wire rst
);

wire[`InstAddrBus] inst_addr;
wire[`InstBus] inst;
wire rom_ce;

cpu cpu0(
  .clk(clk),
  .rst(rst),
  .romData_i(inst),
  .romAddr_o(inst_addr),
  .romEnable_o(rom_ce)
);

inst_rom inst_rom0(
  .ce(rom_ce),
  .addr(inst_addr),
  .inst(inst)
);

endmodule // top

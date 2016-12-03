`include "defines.v"

module id_ex(
  input wire clk,
  input wire rst,
  input wire[`StallRegBus]  stall,
  // input
  // EX
  input wire[`AluOpBus]     aluOp_i,
  input wire[`RegBus]       operand1_i,
  input wire[`RegBus]       operand2_i,
  //MEM
  // WB
  input wire wReg_i,
  input wire[`RegAddrBus]   wRegAddr_i,

  // output
  // EX
  output reg[`AluOpBus]     aluOp_o,
  output reg[`RegBus]       operand1_o,
  output reg[`RegBus]       operand2_o,
  //MEM
  // WB
  output reg                wReg_o,
  output reg[`RegAddrBus]   wRegAddr_o
);

always @ (posedge clk) begin
  if ((rst == `RstEnable) || ((stall[2] == `Stop) & (stall[3] == `NoStop))) begin
    aluOp_o <= `ALU_NOP;
    operand1_o <= `ZeroWord;
    operand2_o <= `ZeroWord;
    wReg_o <= `WriteDisable;
    wRegAddr_o <= `DisableRegAddr;
  end
  else if(stall[2] == `NoStop) begin
    aluOp_o <= aluOp_i;
    operand1_o <= operand1_i;
    operand2_o <= operand2_i;
    // memAddr_o <= memAddr_i;
    wReg_o <= wReg_i;
    wRegAddr_o <= wRegAddr_i;
  end
end

endmodule //id_ex

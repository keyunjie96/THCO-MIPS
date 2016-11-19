`include "defines.v"

module id_ex(
  input wire clk,
  input wire rst,

  // input
  // EX
  input wire[`AluOpBus]     aluOp_i,
  input wire[`RegBus]       operand1_i,
  input wire[`RegBus]       operand2_i,
  // WB
  input wire wReg_i,
  input wire[`RegAddrBus]   wRegAddr_i,

  // output
  // EX
  output reg[`AluOpBus]     aluOp_o,
  output reg[`RegBus]       operand1_o,
  output reg[`RegBus]       operand2_o,
  // WB
  output reg                wReg_o,
  output reg[`RegAddrBus]   wRegAddr_o
);

always @ (posedge clk) begin
  if (rst == `RstEnable) begin
    aluOp_o <= `ALU_NOP;
    operand1_o <= `ZeroWord;
    operand2_o <= `ZeroWord;
    wReg_o <= `Disable;
    wRegAddr_o <= `RegZero;
  end
  else begin
    aluOp_o <= aluOp_i;
    operand1_o <= operand1_i;
    operand2_o <= operand2_i;
    wReg_o <= wReg_i;
    wRegAddr_o <= wRegAddr_i;
  end
end

endmodule //id_ex

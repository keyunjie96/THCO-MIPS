`include "defines.v"

module ex (
  // input
  // EX
  input wire[`AluOpBus]   aluOp_i,
  input wire[`RegBus]     operand1_i,
  input wire[`RegBus]     operand2_i,
  // MEM (blank)
  // WB
  input wire              wReg_i,
  input wire[`RegAddrBus] wRegAddr_i,

  // output
  // MEM-WB
  output reg[`RegBus]     wData_o,
  // WB
  output reg              wReg_o,
  output reg[`RegAddrBus] wRegAddr_o
);

// ALU
always @ ( * ) begin
  case (aluOp_i)
    `ALU_ADD: begin
      wData_o = operand1_i + operand2_i;
    end
    default: begin
      wData_o = `ZeroWord;
    end
  endcase
end

// 向下一级模块传递数据
always @ ( * ) begin
  wReg_o = wReg_i;
  wRegAddr_o = wRegAddr_i;
end

endmodule // ex

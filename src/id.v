`include "defines.v"

module id (
  // 读到的指令
  input wire[`InstAddrBus]    instAddr_i,       // 指令地址
  input wire[`InstBus]        inst_i,           // 指令

  // 从寄存器堆读的数据
  input wire[`RegBus]         reg1Data_i,       // reg1数据
  input wire[`RegBus]         reg2Data_i,       // reg2数据

  // 写到寄存器堆的数据
  output reg                  reg1Enable_o,     // reg1读使能信号
  output reg                  reg2Enable_o,     // reg2读使能信号
  output reg[`RegAddrBus]     reg1Addr_o,       // 读reg1地址
  output reg[`RegAddrBus]     reg2Addr_o,       // 读reg2地址

  // 送往执行段的数据和控制信号
  output reg[`RegBus]         operand1_o,       // alu操作数1
  output reg[`RegBus]         operand2_o,       // alu操作数2
  output reg[`AluOpBus]       aluOp_o,          // alu操作码

  // 送往写回段的数据和控制信号
  output reg[`RegAddrBus]     wRegAddr_o,       // 目的寄存器地址
  output reg                  wReg_o            // 是否有目的寄存器
);

wire[5:0] op = inst_i[15:11];
wire[`RegAddrBus] rx = inst_i[10:8];
wire[`RegAddrBus] ry = inst_i[7:5];
wire[`RegBus] sgnImm5 = {{11{inst_i[4]}}, inst_i[4:0]}; // 符号扩展5位立即数
reg[`RegBus] reg1Data;

// 旁路选择
always @ ( * ) begin
  reg1Data = reg1Data_i;    // TODO: 此处不完整
end

// 译码
always @ ( * ) begin
  case (op)
    `OP_ADDIU3: begin
      // reg
      reg1Enable_o = `Enable;
      reg1Addr_o = rx;
      reg2Enable_o = `Disable;
      // EX
      operand1_o = reg1Data;
      operand2_o = sgnImm5;
      aluOp_o = `ALU_ADD;
      // MEM (blank)
      // WB
      wReg_o = `Enable;
      wRegAddr_o = ry;
    end
    default: begin
      reg1Enable_o = `Disable;
      reg2Enable_o = `Disable;
      operand1_o = `ZeroWord;
      operand2_o = `ZeroWord;
      aluOp_o = `ALU_NOP;
      wReg_o = `Disable;
    end
  endcase
end
endmodule //id

`include "defines.v"

module id (
  input wire                  rst,

  // 读到的指令
  input wire[`InstAddrBus]    instAddr_i,       // 指令地址
  input wire[`InstBus]        inst_i,           // 指令

  // 从寄存器堆读的数据
  input wire[`RegBus]         reg1Data_i,       // reg1数据
  input wire[`RegBus]         reg2Data_i,       // reg2数据

  //接收从执行阶段的运算结果
  input wire                  wReg_ex_i,        //是否有要写入寄存器
  input wire[`RegBus]         wData_ex_i,       //执行阶段结果
  input wire[`RegAddrBus]     wRegAddr_ex_i,    //待写入寄存器地址

  //接收从访存阶段的运算结果
  input wire                  wReg_mem_i,        //是否有要写入寄存器
  input wire[`RegBus]         wData_mem_i,       //执行阶段结果
  input wire[`RegAddrBus]     wRegAddr_mem_i,    //待写入寄存器地址
  
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

//指令和操作码
wire[5:0] op = inst_i[15:11];
wire[`FunctBus3] frontFunct3 = inst_i[10:8];
wire[`FunctBus2] backFunct2 = inst_i[`FunctBus2];
wire[`FunctBus5] backFunct5 = inst_i[`FunctBus5];
wire[`FunctBus8] backFunct8 = inst_i[`FunctBus8];
wire[`FunctBus11] backFunct11 = inst_i[`FunctBus11];


//操作数
wire[`RegAddrBus] rx = inst_i[10:8];
wire[`RegAddrBus] ry = inst_i[7:5];
wire[`RegAddrBus] rz = inst_i[4:2];

//立即数
wire[`RegBus] sgnImm5 = {{11{inst_i[4]}}, inst_i[4:0]}; // 符号扩展5位立即数
wire[`RegBus] sgnImm8 = {{8{inst_i[7]}}, inst_i[7:0]}; // 符号扩展8位立即数
wire[2:0] Imm3 = inst_i[4:2];
reg[`RegBus] reg1Data;
reg[`RegBus] reg2Data;

// 旁路选择 rx
always @ ( * ) begin
  if (rst == `RstEnable) begin
    reg1Data <= `ZeroWord;    
  end else if((reg1Enable_o == `Enable) && (wReg_ex_i == `Enable) && (wRegAddr_ex_i == rx)) begin
    reg1Data <= wData_ex_i;
  end else if((reg1Enable_o == `Enable) && (wReg_mem_i == `Enable) && (wRegAddr_mem_i == rx)) begin
    reg1Data <= wData_mem_i;
  end else if(reg1Enable_o == `Enable) begin
    reg1Data <= reg1Data_i;
  end else begin
    reg1Data <= `ZeroWord;
  end
end

// 旁路选择 ry
always @ ( * ) begin
  if (rst == `RstEnable) begin
    reg2Data <= `ZeroWord;    
  end else if((reg2Enable_o == `Enable) && (wReg_ex_i == `Enable) && (wRegAddr_ex_i == ry)) begin
    reg2Data <= wData_ex_i;
  end else if((reg2Enable_o == `Enable) && (wReg_mem_i == `Enable) && (wRegAddr_mem_i == ry)) begin
    reg2Data <= wData_mem_i;
  end else if(reg2Enable_o == `Enable) begin
    reg2Data <= reg2Data_i;
  end else begin
    reg2Data <= `ZeroWord;
  end
end

// 译码
always @ ( * ) begin
  case (op)
    `OP_ADDIU3: begin
      // reg
      reg1Enable_o = `Enable;
      reg2Enable_o = `Disable;
      reg1Addr_o = rx;
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

`include "defines.v"

module id (
  input wire                  rst,

  // 读到的指令
  input wire[`InstAddrBus]    instAddr_i,       // 指令地址
  input wire[`InstBus]        inst_i,           // 指令

  // 从寄存器堆读的数据
  input wire[`RegBus]         reg1Data_i,       // reg1数据
  input wire[`RegBus]         reg2Data_i,       // reg2数据

  // 直接接收pc寄存器的数据和信号
  input wire                  in_delay_slot_i,  //是否在延迟槽

  //直接接收从执行阶段的数据和控制信号
  input wire                  wReg_ex_i,        //是否有要写入寄存器
  input wire[`RegBus]         wData_ex_i,       //执行阶段结果
  input wire[`RegAddrBus]     wRegAddr_ex_i,    //待写入寄存器地址
  input wire[`AluOpBus]       aluOp_ex_i,       //执行阶段运算情况

  //直接接收从访存阶段的运算结果
  input wire                  wReg_mem_i,        //是否有要写入寄存器
  input wire[`RegBus]         wData_mem_i,       //执行阶段结果
  input wire[`RegAddrBus]     wRegAddr_mem_i,    //待写入寄存器地址

  //写到寄存器堆的数据
  output reg                  reg1Enable_o,     // reg1读使能信号
  output reg                  reg2Enable_o,     // reg2读使能信号
  output reg[`RegAddrBus]     reg1Addr_o,       // 读reg1地址
  output reg[`RegAddrBus]     reg2Addr_o,       // 读reg2地址

  //直接送往pc寄存器的数据和控制信号
  output reg                  jump_o,
  output reg[`RegBus]         jump_target_addr_o,

  // 送往执行段的数据和控制信号
  output reg[`RegBus]         operand1_o,       // alu操作数1
  output reg[`RegBus]         operand2_o,       // alu操作数2
  output reg[`AluOpBus]       aluOp_o,          // alu操作码

  // 送往写回段的数据和控制信号
  output reg[`RegAddrBus]     wRegAddr_o,       // 目的寄存器地址
  output reg                  wReg_o,           // 是否有目的寄存器

  //控制流水线暂停
  output reg                  stall_request
);

//暂停信号
reg stall_request_from_reg1;
reg stall_request_from_reg2;

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
wire[`RegBus] sgnImm4 = {{12{inst_i[3]}}, inst_i[3:0]}; // 符号扩展4位立即数
wire[`RegBus] sgnImm5 = {{11{inst_i[4]}}, inst_i[4:0]}; // 符号扩展5位立即数
wire[`RegBus] sgnImm8 = {{8{inst_i[7]}}, inst_i[7:0]}; // 符号扩展8位立即数
wire[`RegBus] sgnImm11 = {{5{inst_i[10]}}, inst_i[10:0]}; // 符号扩展11位立即数
wire[`RegBus] zeroImm8 = {{8{1'b0}}, inst_i[7:0]}; // 零位扩展8位立即数
wire[`RegBus] Imm3 = {{15{1'b0}}, inst_i[4:2]};
reg[`RegBus] reg1Data;
reg[`RegBus] reg2Data;

// assign stall_request = stall_request_from_reg1 | stall_request_from_reg2;

always @ ( * ) begin
  stall_request <= stall_request_from_reg1 | stall_request_from_reg2;
end

// 旁路选择 rx
always @ ( * ) begin
  stall_request_from_reg1 <= `Disable;
  if (rst == `RstEnable) begin
    reg1Data <= `ZeroWord;
  end else if ((reg1Enable_o == `Enable) && (aluOp_ex_i == `ALU_LW) && (wRegAddr_ex_i == reg1Addr_o)) begin
    stall_request_from_reg1 <= `Enable;
    reg1Data <= `ZeroWord;
  end else if((reg1Enable_o == `Enable) && (wReg_ex_i == `Enable) && (wRegAddr_ex_i == reg1Addr_o)) begin
    reg1Data <= wData_ex_i;
  end else if((reg1Enable_o == `Enable) && (wReg_mem_i == `Enable) && (wRegAddr_mem_i == reg1Addr_o)) begin
    reg1Data <= wData_mem_i;
  end else if(reg1Enable_o == `Enable) begin
    reg1Data <= reg1Data_i;
  end else begin
    reg1Data <= `ZeroWord;
  end
end

// 旁路选择 ry
always @ ( * ) begin
  stall_request_from_reg2 <= `Disable;
  if (rst == `RstEnable) begin
    reg2Data <= `ZeroWord;
  end else if ((reg2Enable_o == `Enable) && (aluOp_ex_i == `ALU_LW) && (wRegAddr_ex_i == reg2Addr_o)) begin
    stall_request_from_reg2 <= `Enable;
    reg2Data <= `ZeroWord;
  end else if((reg2Enable_o == `Enable) && (wReg_ex_i == `Enable) && (wRegAddr_ex_i == reg2Addr_o)) begin
    reg2Data <= wData_ex_i;
  end else if((reg2Enable_o == `Enable) && (wReg_mem_i == `Enable) && (wRegAddr_mem_i == reg2Addr_o)) begin
    reg2Data <= wData_mem_i;
  end else if(reg2Enable_o == `Enable) begin
    reg2Data <= reg2Data_i;
  end else begin
    reg2Data <= `ZeroWord;
  end
end

// 译码
always @ ( * ) begin
  // pc
  jump_o <= `Disable;
  case (op)
    `OP_NOP:  begin
      // reg
      reg1Enable_o <= `Disable;
      reg2Enable_o <= `Disable;
      reg1Addr_o <= `ZeroWord;
      reg2Addr_o <= `ZeroWord;
      // EX
      operand1_o <= `ZeroWord;
      operand2_o <= `ZeroWord;
      aluOp_o <= `ALU_NOP;
      // MEM (blank)
      // WB
      wReg_o <= `Disable;
      wRegAddr_o <= `ZeroWord;
    end
    `OP_B:  begin
      // reg
      reg1Enable_o <= `Disable;
      reg2Enable_o <= `Disable;
      reg1Addr_o <= `ZeroWord;
      reg2Addr_o <= `ZeroWord;
      // EX
      operand1_o <= `ZeroWord;
      operand2_o <= `ZeroWord;
      aluOp_o <= `ALU_NOP;
      // MEM (blank)
      // WB
      wReg_o <= `Disable;
      wRegAddr_o <= `ZeroWord;
      // pc
      if (in_delay_slot_i == `Disable) begin
        jump_o <= `Enable;
        jump_target_addr_o <= instAddr_i + sgnImm11 + `PcUnit;
      end
    end
    `OP_BEQZ: begin
      // reg
      reg1Enable_o <= `Enable;
      reg2Enable_o <= `Disable;
      reg1Addr_o <= rx;
      reg2Addr_o <= `ZeroWord;
      // EX
      operand1_o <= `ZeroWord;
      operand2_o <= `ZeroWord;
      aluOp_o <= `ALU_NOP;
      // MEM (blank)
      // WB
      wReg_o <= `Disable;
      wRegAddr_o <= `ZeroWord;
      // pc
      if ((reg1Data == `ZeroWord) && (in_delay_slot_i == `Disable)) begin
        jump_o <= `Enable;
        jump_target_addr_o <= instAddr_i + sgnImm8 + `PcUnit;
      end
    end
    `OP_BNEZ: begin
      // reg
      reg1Enable_o <= `Enable;
      reg2Enable_o <= `Disable;
      reg1Addr_o <= rx;
      reg2Addr_o <= `ZeroWord;
      // EX
      operand1_o <= `ZeroWord;
      operand2_o <= `ZeroWord;
      aluOp_o <= `ALU_NOP;
      // MEM (blank)
      // WB
      wReg_o <= `Disable;
      wRegAddr_o <= `ZeroWord;
      // pc
      if ((reg1Data != `ZeroWord) && (in_delay_slot_i == `Disable)) begin
        jump_o <= `Enable;
        jump_target_addr_o <= instAddr_i + sgnImm8 + `PcUnit;
      end
    end
    `OP_SLL_SRA: begin
      // reg
      reg1Enable_o <= `Enable;
      reg2Enable_o <= `Disable;
      reg1Addr_o <= ry;
      reg2Addr_o <= `ZeroWord;
      // EX
      operand1_o <= reg1Data;
      operand2_o <= Imm3;
      aluOp_o <= backFunct2 == `FUNCT_SLL ? `ALU_SLL : `ALU_SRA;
      // MEM (blank)
      // WB
      wReg_o <= `Enable;
      wRegAddr_o <= rx;
    end
    `OP_ADDIU3: begin
      // reg
      reg1Enable_o <= `Enable;
      reg2Enable_o <= `Disable;
      reg1Addr_o <= rx;
      reg2Addr_o <= `ZeroWord;
      // EX
      operand1_o <= reg1Data;
      operand2_o <= sgnImm4;
      aluOp_o <= `ALU_ADD;
      // MEM (blank)
      // WB
      wReg_o <= `Enable;
      wRegAddr_o <= ry;
    end
    `OP_ADDIU: begin
      // reg
      reg1Enable_o <= `Enable;
      reg2Enable_o <= `Disable;
      reg1Addr_o <= rx;
      reg2Addr_o <= `ZeroWord;
      // EX
      operand1_o <= reg1Data;
      operand2_o <= sgnImm8;
      aluOp_o <= `ALU_ADD;
      // MEM (blank)
      // WB
      wReg_o <= `Enable;
      wRegAddr_o <= rx;
    end
    `OP_SLTI: begin
      // reg
      reg1Enable_o <= `Enable;
      reg2Enable_o <= `Disable;
      reg1Addr_o <= rx;
      reg2Addr_o <= `ZeroWord;
      // EX
      operand1_o <= reg1Data;
      operand2_o <= sgnImm8;
      aluOp_o <= `ALU_SLT;
      // MEM (blank)
      // WB
      wReg_o <= `Enable;
      wRegAddr_o <= `REG_T;
    end
    `OP_BTEQZ_MTSP_ADDSP: begin
      case (frontFunct3)
        `FUNCT_BTEQZ: begin
          // reg
          reg1Enable_o <= `Enable;
          reg2Enable_o <= `Disable;
          reg1Addr_o <= `REG_T;
          reg2Addr_o <= `ZeroWord;
          // EX
          operand1_o <= `ZeroWord;
          operand2_o <= `ZeroWord;
          aluOp_o <= `ALU_NOP;
          // MEM (blank)
          // WB
          wReg_o <= `Disable;
          wRegAddr_o <= `ZeroWord;
          // pc
          if ((reg1Data == `ZeroWord) && (in_delay_slot_i == `Disable)) begin
            jump_o <= `Enable;
            jump_target_addr_o <= instAddr_i + sgnImm8 + `PcUnit;
          end
        end
        `FUNCT_MTSP: begin
          // reg
          reg1Enable_o <= `Enable;
          reg2Enable_o <= `Disable;
          reg1Addr_o <= ry;
          reg2Addr_o <= `ZeroWord;
          // EX
          operand1_o <= reg1Data;
          operand2_o <= `ZeroWord;
          aluOp_o <= `ALU_OR;
          // MEM (blank)
          // WB
          wReg_o <= `Enable;
          wRegAddr_o <= `REG_SP;
        end
        `FUNCT_ADDSP: begin
          // reg
          reg1Enable_o <= `Enable;
          reg2Enable_o <= `Disable;
          reg1Addr_o <= `REG_SP;
          reg2Addr_o <= `ZeroWord;
          // EX
          operand1_o <= reg1Data;
          operand2_o <= sgnImm8;
          aluOp_o <= `ALU_ADD;
          // MEM (blank)
          // WB
          wReg_o <= `Enable;
          wRegAddr_o <= `REG_SP;
        end
      endcase
    end
    `OP_LI: begin
      // reg
      reg1Enable_o <= `Disable;
      reg2Enable_o <= `Disable;
      reg1Addr_o <= `ZeroWord;
      reg2Addr_o <= `ZeroWord;
      // EX
      operand1_o <= zeroImm8;
      operand2_o <= `ZeroWord;
      aluOp_o <= `ALU_OR;
      // MEM (blank)
      // WB
      wReg_o <= `Enable;
      wRegAddr_o <= rx;
    end
    `OP_CMPI: begin
      // reg
      reg1Enable_o <= `Enable;
      reg2Enable_o <= `Disable;
      reg1Addr_o <= rx;
      reg2Addr_o <= `ZeroWord;
      // EX
      operand1_o <= reg1Data;
      operand2_o <= sgnImm8;
      aluOp_o <= `ALU_CMP;
      // MEM (blank)
      // WB
      wReg_o <= `Enable;
      wRegAddr_o <= `REG_T;
    end
    `OP_LW_SP: begin
      // reg
      reg1Enable_o <= `Enable;
      reg2Enable_o <= `Disable;
      reg1Addr_o <= `REG_SP;
      reg2Addr_o <= `ZeroWord;
      // EX
      operand1_o <= reg1Data;
      operand2_o <= sgnImm8;
      aluOp_o <= `ALU_LW;
      // WB
      wReg_o <= `Enable;
      wRegAddr_o <= rx;
    end
    `OP_LW: begin
      // reg
      reg1Enable_o <= `Enable;
      reg2Enable_o <= `Disable;
      reg1Addr_o <= rx;
      reg2Addr_o <= `ZeroWord;
      // EX
      operand1_o <= reg1Data;
      operand2_o <= sgnImm5;
      aluOp_o <= `ALU_LW;
      // WB
      wReg_o <= `Enable;
      wRegAddr_o <= ry;
    end
    `OP_SW_SP: begin
      // reg
      reg1Enable_o <= `Enable;
      reg2Enable_o <= `Enable;
      reg1Addr_o <= `REG_SP;
      reg2Addr_o <= rx;
      // EX
      operand1_o <= reg1Data + sgnImm8;
      operand2_o <= reg2Data;
      aluOp_o <= `ALU_SW;
      // WB
      wReg_o <= `Disable;
      wRegAddr_o <= `ZeroWord;
    end
    `OP_SW: begin
      // reg
      reg1Enable_o <= `Enable;
      reg2Enable_o <= `Enable;
      reg1Addr_o <= rx;
      reg2Addr_o <= ry;
      // EX
      operand1_o <= reg1Data + sgnImm5;
      operand2_o <= reg2Data;
      aluOp_o <= `ALU_SW;
      // WB
      wReg_o <= `Disable;
      wRegAddr_o <= `ZeroWord;
    end


    `OP_TRINARY: begin
      case(backFunct2)
        `FUNCT_ADDU: begin
          // reg
          reg1Enable_o <= `Enable;
          reg2Enable_o <= `Enable;
          reg1Addr_o <= rx;
          reg2Addr_o <= ry;
          // EX
          operand1_o <= reg1Data;
          operand2_o <= reg2Data;
          aluOp_o <= `ALU_ADD;
          // MEM (blank)
          // WB
          wReg_o <= `Enable;
          wRegAddr_o <= rz;
        end
        `FUNCT_SUBU: begin
          // reg
          reg1Enable_o <= `Enable;
          reg2Enable_o <= `Enable;
          reg1Addr_o <= rx;
          reg2Addr_o <= ry;
          // EX
          operand1_o <= reg1Data;
          operand2_o <= reg2Data;
          aluOp_o <= `ALU_SUB;
          // MEM (blank)
          // WB
          wReg_o <= `Enable;
          wRegAddr_o <= rz;
        end
        default: begin
        end
      endcase
    end
    `OP_LOGIC_JUMP: begin
      case(backFunct5)
        `FUNCT_AND: begin
          // reg
          reg1Enable_o <= `Enable;
          reg2Enable_o <= `Enable;
          reg1Addr_o <= rx;
          reg2Addr_o <= ry;
          // EX
          operand1_o <= reg1Data;
          operand2_o <= reg2Data;
          aluOp_o <= `ALU_AND;
          // MEM (blank)
          // WB
          wReg_o <= `Enable;
          wRegAddr_o <= rx;
        end
        `FUNCT_OR: begin
          // reg
          reg1Enable_o <= `Enable;
          reg2Enable_o <= `Enable;
          reg1Addr_o <= rx;
          reg2Addr_o <= ry;
          // EX
          operand1_o <= reg1Data;
          operand2_o <= reg2Data;
          aluOp_o <= `ALU_OR;
          // MEM (blank)
          // WB
          wReg_o <= `Enable;
          wRegAddr_o <= rx;
        end
        `FUNCT_NOT: begin
          // reg
          reg1Enable_o <= `Enable;
          reg2Enable_o <= `Disable;
          reg1Addr_o <= ry;
          reg2Addr_o <= `ZeroWord;
          // EX
          operand1_o <= reg1Data;
          operand2_o <= `ZeroWord;
          aluOp_o <= `ALU_NOT;
          // MEM (blank)
          // WB
          wReg_o <= `Enable;
          wRegAddr_o <= rx;
        end
        `FUNCT_OR: begin
          // reg
          reg1Enable_o <= `Enable;
          reg2Enable_o <= `Enable;
          reg1Addr_o <= rx;
          reg2Addr_o <= ry;
          // EX
          operand1_o <= reg1Data;
          operand2_o <= reg2Data;
          aluOp_o <= `ALU_CMP;
          // MEM (blank)
          // WB
          wReg_o <= `Enable;
          wRegAddr_o <= `REG_T;
        end
        `FUNCT_CMP: begin
          // reg
          reg1Enable_o <= `Enable;
          reg2Enable_o <= `Enable;
          reg1Addr_o <= rx;
          reg2Addr_o <= ry;
          // EX
          operand1_o <= reg1Data;
          operand2_o <= reg2Data;
          aluOp_o <= `ALU_CMP;
          // MEM (blank)
          // WB
          wReg_o <= `Enable;
          wRegAddr_o <= `REG_T;
        end
        default: begin
        end
      endcase
      case(backFunct8)
        `FUNCT_MFPC: begin
          // reg
          reg1Enable_o <= `Disable;
          reg2Enable_o <= `Disable;
          reg1Addr_o <= `ZeroWord;
          reg2Addr_o <= `ZeroWord;
          // EX
          operand1_o <= instAddr_i;
          operand2_o <= `PcUnit;
          aluOp_o <= `ALU_ADD;
          // MEM (blank)
          // WB
          wReg_o <= `Enable;
          wRegAddr_o <= rx;
        end
        `FUNCT_JR: begin
          // reg
          reg1Enable_o <= `Enable;
          reg2Enable_o <= `Disable;
          reg1Addr_o <= rx;
          reg2Addr_o <= `ZeroWord;
          // EX
          operand1_o <= `ZeroWord;
          operand2_o <= `ZeroWord;
          aluOp_o <= `ALU_NOP;
          // MEM (blank)
          // WB
          wReg_o <= `Disable;
          wRegAddr_o <= `ZeroWord;
          // pc
          if (in_delay_slot_i == `Disable) begin
            jump_o <= `Enable;
            jump_target_addr_o <= reg1Data;
          end
        end
        `FUNCT_JALR: begin
          // reg
          reg1Enable_o <= `Enable;
          reg2Enable_o <= `Disable;
          reg1Addr_o <= rx;
          reg2Addr_o <= `ZeroWord;
          // EX
          operand1_o <= instAddr_i;
          operand2_o <= `PcUnit + `PcUnit;
          aluOp_o <= `ALU_ADD;
          // MEM (blank)
          // WB
          wReg_o <= `Enable;
          wRegAddr_o <= `REG_RA;
          // pc
          if (in_delay_slot_i == `Disable) begin
            jump_o <= `Enable;
            jump_target_addr_o <= reg1Data;
          end
        end
        default: begin
        end
      endcase
      case(backFunct11)
        `FUNCT_JRRA: begin
          // reg
          reg1Enable_o <= `Enable;
          reg2Enable_o <= `Disable;
          reg1Addr_o <= `REG_RA;
          reg2Addr_o <= `ZeroWord;
          // EX
          operand1_o <= `ZeroWord;
          operand2_o <= `ZeroWord;
          aluOp_o <= `ALU_NOP;
          // MEM (blank)
          // WB
          wReg_o <= `Disable;
          wRegAddr_o <= `ZeroWord;
          // pc
          if (in_delay_slot_i == `Disable) begin
            jump_o <= `Enable;
            jump_target_addr_o <= reg1Data;
          end
        end
        default: begin
        end
      endcase
    end
    `OP_MFIH_MTIH: begin
      case(backFunct8)
        `FUNCT_MFIH: begin
          // reg
          reg1Enable_o <= `Enable;
          reg2Enable_o <= `Disable;
          reg1Addr_o <= `REG_IH;
          reg2Addr_o <= `ZeroWord;
          // EX
          operand1_o <= reg1Data;
          operand2_o <= `ZeroWord;
          aluOp_o <= `ALU_OR;
          // MEM (blank)
          // WB
          wReg_o <= `Enable;
          wRegAddr_o <= rx;
        end
        `FUNCT_MTIH: begin
          // reg
          reg1Enable_o <= `Enable;
          reg2Enable_o <= `Disable;
          reg1Addr_o <= rx;
          reg2Addr_o <= `ZeroWord;
          // EX
          operand1_o <= reg1Data;
          operand2_o <= `ZeroWord;
          aluOp_o <= `ALU_OR;
          // MEM (blank)
          // WB
          wReg_o <= `Enable;
          wRegAddr_o <= `REG_IH;
        end
        default: begin
        end
      endcase
    end
    default: begin
      reg1Enable_o <= `Disable;
      reg2Enable_o <= `Disable;
      operand1_o <= `ZeroWord;
      operand2_o <= `ZeroWord;
      aluOp_o <= `ALU_NOP;
      wReg_o <= `Disable;
    end
  endcase
end
endmodule //id

`include "defines.v"

module ex (
  // input
  // EX
  input wire[`AluOpBus]   aluOp_i,
  input wire[`RegBus]     operand1_i,
  input wire[`RegBus]     operand2_i,
  //MEM
  // WB
  input wire              wReg_i,
  input wire[`RegAddrBus] wRegAddr_i,

  // output
  // ID
  output reg[`AluOpBus]       aluOp_o,
  // MEM
  output reg[`MemAddrBus]     memAddr_o,       // 内存地址
  output reg                  rMem_o,          // 是否读取内存
  output reg                  wMem_o,          // 是否写入内存 
  // MEM-WB  
  output reg[`RegBus]     wData_o,
  // WB
  output reg              wReg_o,
  output reg[`RegAddrBus] wRegAddr_o
);

// ALU
always @ ( * ) begin
  rMem_o <= `ReadDisable;
  wMem_o <= `WriteDisable;
  case (aluOp_i)
    `ALU_NOP: begin
    end
    `ALU_ADD: begin
      wData_o <= operand1_i + operand2_i;
    end
    `ALU_SUB: begin
      wData_o <= operand1_i - operand2_i;
    end
    `ALU_AND: begin
      wData_o <= operand1_i & operand2_i;
    end
    `ALU_OR: begin
      wData_o <= operand1_i | operand2_i;
    end
    `ALU_NOT: begin
      wData_o <= ~operand1_i;
    end
    `ALU_SLL: begin
      if (operand2_i[2:0] == 3'b000) begin
        wData_o <=operand1_i << 8;
      end
      else begin
        wData_o <= operand1_i << operand2_i[2:0];
      end
    end
    `ALU_SRA: begin
      if (operand2_i[2:0] == 3'b000) begin
        wData_o <= {16{operand1_i[15]}}<<8 | (operand1_i >> 8);
      end
      else begin
        wData_o <= ({16{operand1_i[15]}}<<(16-operand2_i[2:0])) | (operand1_i >> operand2_i[2:0]);
      end
    end
    `ALU_SLT: begin
      if (((operand1_i[14:0] < operand2_i[14:0]) && (operand1_i[15] == operand2_i[15])) || 
      ((operand1_i[15] == 1'b1) && (operand2_i[15] == 1'b0))) begin
        wData_o <= 1'b1;
      end
      else begin
        wData_o <= 1'b0;
      end
    end
    `ALU_CMP: begin
      wData_o <= operand1_i == operand2_i ? 1'b0 : 1'b1;
    end
    `ALU_SW: begin
      wMem_o <= `WriteEnable;
      memAddr_o <= operand1_i;
      wData_o <= operand2_i;
    end
    `ALU_LW: begin
      rMem_o <= `ReadEnable;
      memAddr_o <= operand1_i + operand2_i;
    end
    default: begin
      wData_o <= `ZeroWord;
    end
  endcase
end

// 向下一级模块传递数据
always @ ( * ) begin
  // ID
  aluOp_o <= aluOp_i;
  // WB
  wReg_o <= wReg_i;
  wRegAddr_o <= wRegAddr_i;
end

endmodule // ex

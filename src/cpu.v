`include "defines.v"

module cpu (
  input wire            clk,
  input wire            rst,

  input wire[`RegBus]   romData_i,
  output wire[`RegBus]  romAddr_o,
  output wire           romEnable_o
);

// 连接IF/ID和ID
wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_inst_i;
wire[`InstBus] id_instAddr_i;

// 连接ID和regfile
wire reg_rEnable1_i;
wire[`RegAddrBus] reg_rAddr1_i;
wire[`RegBus] reg_rData1_o;
wire reg_rEnable2_i;
wire[`RegAddrBus] reg_rAddr2_i;
wire[`RegBus] reg_rData2_o;


// 连接ID和ID/EX
wire[`AluOpBus] id_aluOp_o;
wire[`RegBus] id_operand1_o;
wire[`RegBus] id_operand2_o;
wire[`RegAddrBus] id_wRegAddr_o;
wire id_wReg_o;

// 连接ID/EX和EX
wire[`AluOpBus] ex_aluOp_i;
wire[`RegBus] ex_operand1_i;
wire[`RegBus] ex_operand2_i;
wire ex_wReg_i;
wire[`RegAddrBus] ex_wRegAddr_i;

// 连接EX和EX/MEM
wire[`RegBus] ex_wData_o;
wire ex_wReg_o;
wire[`RegAddrBus] ex_wRegAddr_o;

// 连接EX/MEM和MEM
wire[`RegBus] mem_wData_i;
wire mem_wReg_i;
wire[`RegAddrBus] mem_wRegAddr_i;

// 连接MEM和MEM/WB
wire[`RegBus] mem_wData_o;
wire mem_wReg_o;
wire[`RegAddrBus] mem_wRegAddr_o;

// 连接MEM/WB和regfile
wire reg_wEnable_i;
wire[`RegAddrBus] reg_wAddr_i;
wire[`RegBus] reg_wData_i;

// pc
pc_reg pc_reg0(
  .clk(clk),
  .rst(rst),
  .pc(pc),
  .ce(romEnable_o)
);

assign rom_addr_o = pc;

// IF/ID
if_id if_id0(
  .clk(clk),
  .rst(rst),
  .inst_i(romData_i),
  .instAddr_i(pc),
  .inst_o(id_inst_i),
  .instAddr_o(id_instAddr_i)
);

id id0(
  .inst_i(id_inst_i),
  .instAddr_i(id_instAddr_i),
  .reg1Data_i(reg_rData1_o),
  .reg2Data_i(reg_rData2_o),
  .reg1Enable_o(reg_rEnable1_i),
  .reg2Enable_o(reg_rEnable2_i),
  .reg1Addr_o(reg_rAddr1_i),
  .reg2Addr_o(reg_rAddr2_i),
  .operand1_o(id_operand1_o),
  .operand2_o(id_operand2_o),
  .aluOp_o(id_aluOp_o),
  .wRegAddr_o(id_wRegAddr_o),
  .wReg_o(id_wReg_o)
);

regfile regfile0(
  .clk(clk),
  .rst(rst),
  .wEnable_i(reg_wEnable_i),
  .wAddr_i(reg_wAddr_i),
  .wData_i(reg_wData_i),
  .rEnable1_i(reg_rEnable2_i),
  .rEnable2_i(reg_rEnable2_i),
  .rAddr1_i(reg_rAddr1_i),
  .rAddr2_i(reg_rAddr2_i),
  .rData1_o(reg_rData1_o),
  .rData2_o(reg_rData2_o)
);

id_ex id_ex0(
  .clk(clk),
  .rst(rst),
  .aluOp_i(id_aluOp_o),
  .operand1_i(id_operand1_o),
  .operand2_i(id_operand2_o),
  .wReg_i(id_wReg_o),
  .wRegAddr_i(id_wRegAddr_o),
  .aluOp_o(ex_aluOp_i),
  .wReg_o(ex_wReg_i),
  .wRegAddr_o(ex_wRegAddr_i)
);


ex ex0(
  .aluOp_i(ex_aluOp_i),
  .operand1_i(ex_operand1_i),
  .operand2_i(ex_operand2_i),
  .wReg_i(ex_wReg_i),
  .wRegAddr_i(ex_wRegAddr_i),
  .wData_o(ex_wData_o),
  .wReg_o(ex_wReg_o),
  .wRegAddr_o(ex_wRegAddr_o)
);

ex_mem ex_mem0(
  .clk(clk),
  .rst(rst),
  .wData_i(ex_wData_o),
  .wReg_i(ex_wReg_o),
  .wRegAddr_i(ex_wRegAddr_o),
  .wData_o(mem_wData_i),
  .wReg_o(mem_wReg_i),
  .wRegAddr_o(mem_wRegAddr_i)
);

mem mem0(
  .wData_i(mem_wData_i),
  .wReg_i(mem_wReg_i),
  .wRegAddr_i(mem_wRegAddr_i),
  .wData_o(mem_wData_o),
  .wReg_o(mem_wReg_o),
  .wRegAddr_o(mem_wRegAddr_o)
);

mem_wb mem_wb0(
  .clk(clk),
  .rst(rst),
  .wData_i(mem_wData_o),
  .wReg_i(mem_wReg_o),
  .wRegAddr_i(mem_wRegAddr_i),
  .wData_o(reg_wData_i),
  .wReg_o(reg_wEnable_i),
  .wRegAddr_o(reg_wAddr_i)
);

endmodule // cpu
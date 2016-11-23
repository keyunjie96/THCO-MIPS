`include "defines.v"

module cpu (
  input wire            clk,
  input wire            rst,

  input wire[`RegBus]   instData_i,
  output wire[`RegBus]  instAddr_o,
  output wire           instEnable_o
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

// 连接EX和EX/MEM，EX和ID
wire[`RegBus] ex_wData_o;
wire ex_wReg_o;
wire[`RegAddrBus] ex_wRegAddr_o;

// 连接EX/MEM和MEM，MEM和ID
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
  .ce(instEnable_o)
);

assign instAddr_o = pc;

// IF/ID
if_id if_id0(
  .clk(clk),
  .rst(rst),
  .inst_i(instData_i),
  .instAddr_i(pc),
  .inst_o(id_inst_i),
  .instAddr_o(id_instAddr_i)
);

id id0(
  .rst(rst),
  // 读到的指令
  .inst_i(id_inst_i),
  .instAddr_i(id_instAddr_i),
  // 从寄存器堆读的数据
  .reg1Data_i(reg_rData1_o),
  .reg2Data_i(reg_rData2_o),
  //接收从执行阶段的运算结果
  .wReg_ex_i(ex_wReg_o),              //是否有要写入寄存器
  .wData_ex_i(ex_wData_o),            //执行阶段结果
  .wRegAddr_ex_i(ex_wRegAddr_o),      //待写入寄存器地址

  //接收从访存阶段的运算结果
  .wReg_mem_i(mem_wReg_o),            //是否有要写入寄存器
  .wData_mem_i(mem_wData_o),          //执行阶段结果
  .wRegAddr_mem_i(mem_wRegAddr_o),    //待写入寄存器地址

  // 写到寄存器堆的数据
  .reg1Enable_o(reg_rEnable1_i),
  .reg2Enable_o(reg_rEnable2_i),
  .reg1Addr_o(reg_rAddr1_i),
  .reg2Addr_o(reg_rAddr2_i),
  // 送往执行段的数据和控制信号
  .operand1_o(id_operand1_o),
  .operand2_o(id_operand2_o),
  .aluOp_o(id_aluOp_o),
  // 送往写回段的数据和控制信号
  .wRegAddr_o(id_wRegAddr_o),
  .wReg_o(id_wReg_o)
);

regfile regfile0(
  .clk(clk),
  .rst(rst),
  // 写端口
  .wEnable_i(reg_wEnable_i),
  .wAddr_i(reg_wAddr_i),
  .wData_i(reg_wData_i),
  // 读端口1
  .rEnable1_i(reg_rEnable2_i),
  .rEnable2_i(reg_rEnable2_i),
  .rAddr1_i(reg_rAddr1_i),
  // 读端口2
  .rAddr2_i(reg_rAddr2_i),
  .rData1_o(reg_rData1_o),
  .rData2_o(reg_rData2_o)
);

id_ex id_ex0(
  .clk(clk),
  .rst(rst),
  // input
  // EX
  .aluOp_i(id_aluOp_o),
  .operand1_i(id_operand1_o),
  .operand2_i(id_operand2_o),
  // WB
  .wReg_i(id_wReg_o),
  .wRegAddr_i(id_wRegAddr_o),
  
  // output
  // EX
  .aluOp_o(ex_aluOp_i),
  .operand1_o(ex_operand1_i),
  .operand2_o(ex_operand2_i),
  // WB
  .wReg_o(ex_wReg_i),
  .wRegAddr_o(ex_wRegAddr_i)
);


ex ex0(
  // input
  // EX
  .aluOp_i(ex_aluOp_i),
  .operand1_i(ex_operand1_i),
  .operand2_i(ex_operand2_i),
  // MEM (blank)
  // WB
  .wReg_i(ex_wReg_i),
  .wRegAddr_i(ex_wRegAddr_i),

  // output
  // MEM-WB
  .wData_o(ex_wData_o),
  .wReg_o(ex_wReg_o),
  // WB
  .wRegAddr_o(ex_wRegAddr_o)
);

ex_mem ex_mem0(
  // input
  .clk(clk),
  .rst(rst),
  // MEM-WB
  .wData_i(ex_wData_o),
  // WB
  .wReg_i(ex_wReg_o),
  .wRegAddr_i(ex_wRegAddr_o),

  // output
  // MEM-WB
  .wData_o(mem_wData_i),
  // WB
  .wReg_o(mem_wReg_i),
  .wRegAddr_o(mem_wRegAddr_i)
);

mem mem0(
  // input
  // WB-MEM
  .wData_i(mem_wData_i),
  // WB
  .wReg_i(mem_wReg_i),
  .wRegAddr_i(mem_wRegAddr_i),

  // output
  // WB
  .wData_o(mem_wData_o),
  .wReg_o(mem_wReg_o),
  .wRegAddr_o(mem_wRegAddr_o)
);

mem_wb mem_wb0(
  // input
  .clk(clk),
  .rst(rst),
  // WB
  .wData_i(mem_wData_o),
  .wReg_i(mem_wReg_o),
  .wRegAddr_i(mem_wRegAddr_i),

  // ouput
  // WB
  .wData_o(reg_wData_i),
  .wReg_o(reg_wEnable_i),
  .wRegAddr_o(reg_wAddr_i)
);

endmodule // cpu

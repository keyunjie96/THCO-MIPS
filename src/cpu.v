`include "defines.v"

module cpu (
  input wire            clk,
  input wire            rst,

  input wire[`RegBus]   instData_i,
  output wire[`RegBus]  instAddr_o,
  output wire           instEnable_o,

  // 给mem_control
  input reg[`MemBus]        memDataRead_i,      // 给MEM的数据
  output wire[`MemAddrBus]  memAddress_o,       // MEM段数据地址
  output wire[`MemBus]      memDataWrite_o,     // MEM段数据
  output wire               memWriteEnable_o,   // MEM写使能
  output wire               memReadEnable_o,    // MEM读使能
  output wire               pauseRequest_o     // 暂停流水线信号
);

// // ctrl模块
wire stall_request_from_id;
wire stall_request_from_mem;
wire[`StallRegBus]  stallCtrl;

// 连接IF/ID和ID
wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_inst_i;
wire[`InstBus] id_instAddr_i;

// 连接pc和ID
wire id_in_delay_slot_i;
wire id_jump_o;
wire[`RegBus] id_jump_target_addr_o;

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
wire id_wReg_o;
wire[`RegAddrBus] id_wRegAddr_o;

// 连接ID/EX和EX
wire[`AluOpBus] ex_aluOp_i;
wire[`RegBus] ex_operand1_i;
wire[`RegBus] ex_operand2_i;
wire ex_wReg_i;
wire[`RegAddrBus] ex_wRegAddr_i;

// 连接EX和EX/MEM，EX和ID
wire[`AluOpBus] ex_aluOp_o;
wire[`RegBus] ex_wData_o;
wire[`MemAddrBus] ex_memAddr_o;
wire ex_rMem_o;
wire ex_wMem_o;
wire ex_wReg_o;
wire[`RegAddrBus] ex_wRegAddr_o;

// 连接EX/MEM和MEM，MEM和ID
wire[`RegBus] mem_wData_i;
wire[`MemAddrBus] mem_memAddr_i;
wire mem_rMem_i;
wire mem_wMem_i;
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
  .stall(stallCtrl),
  .jump_i(id_jump_o),
  .jump_target_addr_i(id_jump_target_addr_o),
  .in_delay_slot_o(id_in_delay_slot_i),
  .pc(pc),
  .ce(instEnable_o)
);

assign instAddr_o = pc;

ctrl ctrl0(
  .rst(rst),
  .stall_request_from_id(stall_request_from_id),
  .stall_request_from_mem(stall_request_from_mem),
  .stallCtrl(stallCtrl)
);

// IF/ID
if_id if_id0(
  .clk(clk),
  .rst(rst),
  .stall(stallCtrl),
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
  // 直接接收pc寄存器的数据和信号
  .in_delay_slot_i(id_in_delay_slot_i),
  //直接接收从执行阶段的数据和控制信号
  .wReg_ex_i(ex_wReg_o),              //是否有要写入寄存器
  .wData_ex_i(ex_wData_o),            //执行阶段结果
  .wRegAddr_ex_i(ex_wRegAddr_o),      //待写入寄存器地址
  .aluOp_ex_i(ex_aluOp_o),

  //接收从访存阶段的运算结果
  .wReg_mem_i(mem_wReg_o),            //是否有要写入寄存器
  .wData_mem_i(mem_wData_o),          //执行阶段结果
  .wRegAddr_mem_i(mem_wRegAddr_o),    //待写入寄存器地址

  // 写到寄存器堆的数据
  .reg1Enable_o(reg_rEnable1_i),
  .reg2Enable_o(reg_rEnable2_i),
  .reg1Addr_o(reg_rAddr1_i),
  .reg2Addr_o(reg_rAddr2_i),
  //直接送往pc寄存器的数据和控制信号
  .jump_o(id_jump_o),
  .jump_target_addr_o(id_jump_target_addr_o),
  // 送往执行段的数据和控制信号
  .operand1_o(id_operand1_o),
  .operand2_o(id_operand2_o),
  .aluOp_o(id_aluOp_o),
  // 送往写回段的数据和控制信号
  .wRegAddr_o(id_wRegAddr_o),
  .wReg_o(id_wReg_o),
  //控制流水线暂停
  .stall_request(stall_request_from_id)
);

regfile regfile0(
  .clk(clk),
  .rst(rst),
  // 执行阶段要写入的地址，主要是BTEQZ需要在ID段进行判断，而上条指令尚在EX段
  .wEnable_ex_i(ex_wReg_o),
  .wAddr_ex_i(ex_wRegAddr_o),
  .wData_ex_i(ex_wData_o),
  // 写端口
  .wEnable_i(reg_wEnable_i),
  .wAddr_i(reg_wAddr_i),
  .wData_i(reg_wData_i),
  // 读端口1
  .rEnable1_i(reg_rEnable1_i),
  .rAddr1_i(reg_rAddr1_i),
  .rData1_o(reg_rData1_o),
  // 读端口2
  .rEnable2_i(reg_rEnable2_i),
  .rAddr2_i(reg_rAddr2_i),
  .rData2_o(reg_rData2_o)
);

id_ex id_ex0(
  // input
  .clk(clk),
  .rst(rst),
  .stall(stallCtrl),
  // EX
  .aluOp_i(id_aluOp_o),
  .operand1_i(id_operand1_o),
  .operand2_i(id_operand2_o),
  // MEM
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
  // MEM
  // WB
  .wReg_i(ex_wReg_i),
  .wRegAddr_i(ex_wRegAddr_i),

  // output
  //
  .aluOp_o(ex_aluOp_o),
  // MEM
  .memAddr_o(ex_memAddr_o),
  .rMem_o(ex_rMem_o),
  .wMem_o(ex_wMem_o),
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
  .stall(stallCtrl),
  // MEM
  .memAddr_i(ex_memAddr_o),
  .rMem_i(ex_rMem_o),
  .wMem_i(ex_wMem_o),
  // MEM-WB
  .wData_i(ex_wData_o),
  // WB
  .wReg_i(ex_wReg_o),
  .wRegAddr_i(ex_wRegAddr_o),

  // output
  // MEM
  .memAddr_o(mem_memAddr_i),
  .rMem_o(mem_rMem_i),
  .wMem_o(mem_wMem_i),
  // MEM-WB
  .wData_o(mem_wData_i),
  // WB
  .wReg_o(mem_wReg_i),
  .wRegAddr_o(mem_wRegAddr_i)
);

mem mem0(
  // 引到cpu上
  .wData_mem_i(memDataRead_i),
  .memAddr_o(memAddress_o),
  .wData_mem_o(memDataWrite_o),
  .rMem_o(memReadEnable_o),
  .wMem_o(memWriteEnable_o),
  .stall_request(pauseRequest_o),

  // input
  // WB-MEM
  // MEM
  .memAddr_i(mem_memAddr_i),
  .rMem_i(mem_rMem_i),
  .wMem_i(mem_wMem_i),
  .wData_i(mem_wData_i),
  // WB
  .wReg_i(mem_wReg_i),
  .wRegAddr_i(mem_wRegAddr_i),

  // output
  // WB
  .wData_o(mem_wData_o),
  .wReg_o(mem_wReg_o),
  .wRegAddr_o(mem_wRegAddr_o),
  //控制流水线暂停
  .stall_request(stall_request_from_mem)
);

mem_wb mem_wb0(
  // input
  .clk(clk),
  .rst(rst),
  .stall(stallCtrl),
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

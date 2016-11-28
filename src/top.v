`include "defines.v"

module top (
  input wire clk,
  input wire clk_50,
  output wire clk_,
  input wire rst,

  // serial
  input wire data_ready,
  input wire tbre,
  input wire tsre,
  output wire ram1oe,
  output wire ram1we,
  output wire ram1en,
  output wire rdn,
  output wire wrn,
  inout wire[7:0] ram1data,
  // ram2
  output wire ram2oe,
  output wire ram2we,
  output wire ram2en,
  output wire[`MemAddrBus] ram2addr,
  inout wire[`MemBus] ram2data,
  output wire[15:0] led
);

// 连接cpu和mem_control
wire[`InstAddrBus] inst_addr;
wire[`InstBus] inst;
wire rom_ce;
wire[`MemBus]      memDataRead;      // 给MEM的数据
wire[`MemAddrBus]  memAddress;       // MEM段数据地址
wire[`MemBus]      memDataWrite;     // MEM段数据
wire               memWriteEnable;   // MEM写使能
wire               memReadEnable;    // MEM读使能
wire               pauseRequest;     // 暂停流水线信号

// 连接mem_control和mmu
wire[`MemBus] memCtrl_dataRead;
wire[`MemAddrBus] memCtrl_address;
wire[`MemBus] memCtrl_dataWrite;
wire memCtrl_readWrite;
wire memCtrl_enable;

// 连接mmu和RAM
wire ram_enable_in;
wire ram_readWrite_in;
wire[`MemAddrBus] ram_address_in;
wire[`MemBus] ram_data_in;
wire[`MemBus] ram_data_out;

// 连接mmu和uart
wire[`MemBus] serial_dataWrite_o;
wire serial_readWrite_o;
wire serial_enable_o;
wire[`MemBus] serial_dataRead_i;
wire serial_sendComplete_i;
wire serial_receiveComplete_i;


// always @(*) begin
//   a <= inst_addr;
// end

uart uart0(
  //与上层接口
  .clk(clk_50),
  .rst(rst),
  .data_ready(data_ready),
  .tbre(tbre),
  .tsre(tsre),
  .ram1oe(ram1oe),
  .ram1we(ram1we),
  .ram1en(ram1en),
  .rdn(rdn),
  .wrn(wrn),
  .ram1data(ram1data),
  //与同层mem_control接口
  .send_data(serial_dataWrite_o),
  .send_data_complete(serial_sendComplete_i),
  .receive_data_complete(serial_receiveComplete_i),
  .en1(serial_readWrite_o),
  .en2(serial_enable_o),
  .receive_data(serial_dataRead_i)
);

mem_control mem_control0(
  //与同层cpu接口
  .instAddress_i(inst_addr),
  .instData_o(inst),

  .memDataRead_o(memDataRead),
  .memAddress_i(memAddress),
  .memDataWrite_i(memDataWrite),
  .memWriteEnable_i(memWriteEnable),
  .memReadEnable_i(memReadEnable),
  .pauseRequest_i(pauseRequest),

  // 与mmu
  .memDataRead_i(memCtrl_dataRead),
  .memAddress_o(memCtrl_address),
  .memDataWrite_o(memCtrl_dataWrite),
  .memReadWrite_o(memCtrl_readWrite),
  .memEnable_o(memCtrl_enable)
);

mmu mmu0(
    .memAddress_i(memCtrl_address),
    .memDataWrite_i(memCtrl_dataWrite),
    .memReadWrite_i(memCtrl_readWrite),
    .memEnable_i(memCtrl_enable),
    .memDataRead_o(memCtrl_dataRead),
    .ram_enable_o(ram_enable_in),
    .ram_readWrite_o(ram_readWrite_in),
    .ram_address_o(ram_address_in),
    .ram_dataWrite_o(ram_data_in),
    .ram_dataRead_i(ram_data_out),
    // uart
    .serial_dataWrite_o(serial_dataWrite_o),
    .serial_readWrite_o(serial_readWrite_o),
    .serial_enable_o(serial_enable_o),
    .serial_dataRead_i(serial_dataRead_i),
    .serial_sendComplete_i(serial_sendComplete_i),
    .serial_receiveComplete_i(serial_receiveComplete_i)
);

ram_control ram_control0(
    .enable_in(ram_enable_in),
    .readWrite_in(ram_readWrite_in),
    .address_in(ram_address_in),
    .data_in(ram_data_in),
    .data_out(ram_data_out),
    // top
    .ram_oe_out(ram2oe),
    .ram_we_out(ram2we),
    .ram_en_out(ram2en),
    .ram_address_out(ram2addr),
    .ram_data_inout(ram2data)
);

cpu cpu0(
  .clk(clk),
  .rst(rst),
  //与同层mem_control接口
  .instData_i(inst),
  .instAddr_o(inst_addr),
  // .instEnable_o(rom_ce)
  .memDataRead_i(memDataRead),
  .memAddress_o(memAddress),
  .memDataWrite_o(memDataWrite),
  .memWriteEnable_o(memWriteEnable),
  .memReadEnable_o(memReadEnable),
  .pauseRequest_o(pauseRequest)
);

assign led = inst_addr;
assign clk_ = clk_50;

// inst_rom inst_rom0(
//   .ce(rom_ce),
//   .addr(inst_addr),
//   .inst(inst)
// );

endmodule // top

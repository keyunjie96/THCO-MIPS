`include "defines.v"

module top (
  input wire clk,
  // input wire clk_choose,
  input wire clk_50,
  input wire clk_11,
  output wire clk_,
  input wire rst,
  input wire[15:0] sw,

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
  // flash
  output wire flashByte,
  output wire flashVpen,
  output wire flashCe,
  output wire flashOe,
  output wire flashWe,
  output wire flashRp,
  output wire[22:1] flashAddr,
  inout wire[15:0] flashData,
  // VGA
  output wire vgaHs,
  output wire vgaVs,
  output wire[2:0] vgaR,
  output wire[2:0] vgaG,
  output wire[2:0] vgaB,

  output wire[15:0] led,
  //KB
  input wire ps2clock,
  input wire ps2data
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
wire[`HalfWordBus] serial_dataWrite_o;
wire serial_fetch_data_o;
wire serial_readWrite_o;
wire serial_enable_o;
wire[`HalfWordBus] serial_dataRead_i;
wire serial_sendComplete_i;
wire serial_receiveComplete_i;

// 连接flash_io和mem_bridge
wire[22:1] memCtrl_flashAddr;
wire[`MemBus] memCtrl_flashData;
wire memCtrl_flashRead;


// wire[`MemAddrBus] vga_address;
// wire[`MemBus] vga_data_in;
// wire vga_enable;
// wire vga_readWrite;
// wire[15:0] vga_data_out;

// 连接keyboardAdapter和mmu
wire kb_data_receive;
wire kb_data_ready;
wire[7:0] kb_ascii;

// 分频后时钟
wire clock;
wire clk_full;
wire clk_quarter;
wire[1:0] state;

// assign clk_choose = `Disable;
assign clock = sw[0] == `Enable ? clk_11 : clk;

// always @(*) begin
//   a <= inst_addr;
// end

// clock_divider clock_divider0(
//     .clk(clock),
//     .rst(rst),
//     .clk_fast(clk_fast),
//     .clk_slow(clk_slow),
//     .state(state)
// );

uart uart0(
  //与上层接口
  .clk(clk_11),
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
  .en3(serial_fetch_data_o),
  .receive_data(serial_dataRead_i)
);

wire flashWrite;
wire flashErase;

flash_io flash_io0(
    .clk(clk_full),
    .reset(rst),

    // 与mem_bridge接口
    .addr(memCtrl_flashAddr),
    .data_out(memCtrl_flashData),
    .ctl_read(memCtrl_flashRead),

    // 通向flash接口
    .flash_byte(flashByte),
    .flash_vpen(flashVpen),
    .flash_ce(flashCe),
    .flash_oe(flashOe),
    .flash_we(flashWe),
    .flash_rp(flashRp),
    .flash_addr(flashAddr),
    .flash_data(flashData),

    // 不用的接口
    .data_in(`ZeroWord),
    .ctl_write(flashWrite),
    .ctl_erase(flashErase)
);

assign flashWrite = 0;
assign flashErase = 0;

mem_bridge mem_bridge0(
    .clk(clock),
    .rst(rst),
    .sw(sw),

    .clk_full(clk_full),
    .clk_quarter(clk_quarter),

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
    .memEnable_o(memCtrl_enable),

    // 与flash控制器接口
    .flashAddr_o(memCtrl_flashAddr),
    .flashCtl_o(memCtrl_flashRead),
    .flashDataRead_i(memCtrl_flashData),

    // 与RAM接口
    .ramState_o(state)
);

// 连接vga_control和mmu
wire[15:0] vga_numbers1;
wire[15:0] vga_numbers2;

mmu mmu0(
    // .clk(clk_50),
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
    .serial_fetch_data_o(serial_fetch_data_o),
    .serial_readWrite_o(serial_readWrite_o),
    .serial_enable_o(serial_enable_o),
    .serial_dataRead_i(serial_dataRead_i),
    .serial_sendComplete_i(serial_sendComplete_i),
    .serial_receiveComplete_i(serial_receiveComplete_i),
    // vga
    .numbers1_o(vga_numbers1),
    .numbers2_o(vga_numbers2),
    // .vga_enable_o(vga_enable),
    // .vga_address_o(vga_address),
    // .vga_dataWrite_o(vga_data_in),
    // .vga_dataRead_i(vga_data_out),
    // .vga_readWrite_o(vga_readWrite),
    // KeyboardAdapter
    .kb_data_receive(kb_data_receive),
    .kb_data_ready(kb_data_ready),
    .kb_ascii(kb_ascii)
);

ram_control ram_control0(
    .clk(clk_full),
    .rst(rst),
    .enable_in(ram_enable_in),
    .readWrite_in(ram_readWrite_in),
    .address_in(ram_address_in),
    .data_in(ram_data_in),
    .data_out(ram_data_out),
    .state(state),
    // top
    .ram_oe_out(ram2oe),
    .ram_we_out(ram2we),
    .ram_en_out(ram2en),
    .ram_address_out(ram2addr),
    .ram_data_inout(ram2data)
);


vga_control vga_control0(
    .clk(clk_50),
    .rst(rst),
    .hs(vgaHs),
    .vs(vgaVs),
    .r(vgaR),
    .g(vgaG),
    .b(vgaB),
    .numbers1_i(vga_numbers1),
    .numbers2_i(vga_numbers2)
    // .enable(vga_enable),
    // .address_in(vga_address),
    // .data_in(vga_data_in),
    // .readWrite_in(vga_readWrite),
    // .data_out(vga_data_out)
);

KeyboardAdapter KeyboardAdapter0(
    .PS2Data(ps2data),
    .PS2Clock(ps2clock),
    .Clock(clk_fast),
    .Reset(rst),
    .DataReceive(kb_data_receive),
    .DataReady(kb_data_ready),
    .Output(kb_ascii)
);

wire[1:0] vga_update;

// VGAControl VGAControl0(
//     .CLKout(clk_50),
//     .CLKin(clk_50),
//     .Reset(rst),
//     .hs(vgaHs),
//     .vs(vgaVs),
//     .r(vgaR),
//     .g(vgaG),
//     .b(vgaB),
//     .CharWea(vga_enable),
//     .CharAddra(vga_address),
//     .CharDina(vga_data_in),
//     .CharDouta(),
//     .UpdateType(vga_update)
// );

assign vga_update = 2'b00;

cpu cpu0(
  .clk(clk_quarter),
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


assign led[15] = sw[15];
assign led[14] = sw[0];
assign led[13:0] = inst_addr[13:0];

// inst_rom inst_rom0(
//   .ce(rom_ce),
//   .addr(inst_addr),
//   .inst(inst)
// );

endmodule // top

`include "defines.v"

module ram_control (
  input   wire                  enable_in,        // 使能信号
  input   wire                  readWrite_in,     // 0表示读，1表示��
  input   wire[`MemAddrBus]     address_in,
  input   wire[`MemBus]         data_in,
  output  reg[`MemBus]          data_out,
  output  reg                   ram_oe_out,
  output  reg                   ram_we_out,
  output  reg                   ram_en_out,
  output  reg[`MemAddrBus]      ram_address_out,
  inout   wire[`MemBus]         ram_data_inout
  // output  reg                   ram_rdn_out
);

// reg[15:0] inst_mem[0:65535];

// initial $readmemh("src/asm/inst_rom.data", inst_mem);

assign ram_data_inout = readWrite_in == 0 ? `HighZWord : data_in;

always @ ( * ) begin
  if (enable_in == `ChipDisable) begin
    ram_en_out = 1;
  end else begin
     ram_en_out = 1;
     case (readWrite_in)
        `MemRead: begin    // read
          ram_en_out = 0;
          ram_we_out = 1;
          ram_oe_out = 0;
        //   data_out = inst_mem[address_in];
          ram_address_out = address_in;
          data_out = ram_data_inout;
        end
        `MemWrite: begin    // write
        //   inst_mem[address_in] = data_in;
          ram_oe_out = 0;
          ram_we_out = 1;
          ram_address_out = address_in;
          ram_oe_out = 1;
          ram_we_out = 0;
          ram_en_out = 0;
        end
        default: begin
          ram_en_out = 1;
        end
     endcase
  end
end

endmodule // ram_control

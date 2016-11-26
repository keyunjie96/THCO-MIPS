`include "defines.v"

module ram_control (
  input   wire                  clk,
  input   wire                  rst,
  input   wire                  enable_in,        // 使能信号
  input   wire                  readWrite_in,     // 0表示读，1表示��
  input   wire[`MemAddrBus]     address_in,
  input   wire[`MemBus]         data_in,
  output  reg[`MemBus]          data_out,
  output  reg                   ram_oe_out,
  output  reg                   ram_we_out,
  output  reg                   ram_en_out,
  output  reg[`MemAddrBus]      ram_address_out,
  inout   wire[`MemBus]         ram_data_inout,
  output  reg                   ram_rdn_out
);

assign ram_data_inout = readWrite_in == 0 ? `HighZWord : data_in;

always @ ( clk ) begin
  if (enable_in == `ChipDisable) begin
    ram_en_out = 1;
  end else begin
    ram_rdn_out = 1;
    if (clk == 1) begin
      case (readWrite_in)
        0: begin    // read
          ram_en_out = 0;
          ram_we_out = 1;
          ram_oe_out = 0;
          ram_address_out = address_in;
        end
        1: begin    // write
          ram_en_out = 0;
          ram_we_out = 0;
          ram_oe_out = 1;
          ram_address_out = address_in;
        end
        default: begin end
      endcase
    end else begin
      case (readWrite_in)
        0: data_out = ram_data_inout;
        default: begin end
      endcase
    end
  end
end

endmodule // ram_control

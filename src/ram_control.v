`include "defines.v"

module ram_control (
input   wire                  clk,
input   wire                  rst,
input   wire                  enable_in,        // 使能信号
input   wire                  readWrite_in,     // 0表示读，1表示写
input   wire[`MemAddrBus]     address_in,
input   wire[`MemBus]         data_in,
input   wire[1:0]             state,
output  reg[`MemBus]          data_out,
output  reg                   ram_oe_out,
output  reg                   ram_we_out,
output  reg                   ram_en_out,
output  reg[`MemAddrBus]      ram_address_out,
inout   wire[`MemBus]         ram_data_inout
);

reg[`MemBus] dataBuffer;
// reg[1:0] state = 2'b00;
reg[1:0] PREP = 2'b00, VISIT = 2'b01, SET = 2'b11, HOLD = 2'b10;
assign ram_data_inout = ((readWrite_in == 0) )? `HighZWord : data_in;

always @ (negedge clk) begin
    if (rst == `RstEnable || enable_in == `Disable) begin
        // state <= PREP;
        ram_en_out <= 1;
        ram_oe_out <= 1;
        ram_we_out <= 1;
        dataBuffer <= `ZeroWord;
    end else begin
        case (state)
            PREP: begin
                if (readWrite_in == `MemRead) begin
                    ram_en_out <= 1;
                    ram_oe_out <= 1;
                    ram_we_out <= 1;
                end else begin
                    ram_en_out <= 1;
                    ram_oe_out <= 1;
                    ram_we_out <= 1;
                end
                // state <= VISIT;
            end
            VISIT: begin
                ram_address_out <= address_in;
                // state <= SET;
            end
            SET: begin
                if (readWrite_in == `MemRead) begin
                    ram_en_out <= 0;
                    ram_oe_out <= 0;
                    ram_we_out <= 1;
                    // data_out <= data[ram_address_out];
                end else begin
                    ram_en_out <= 0;
                    ram_oe_out <= 1;
                    ram_we_out <= 0;
                    // data[ram_address_out] <= ram_data_inout;
                end
                // state <= HOLD;
            end
            HOLD: begin
                if (readWrite_in == `MemRead) begin
                    // data_out <= data[ram_address_out];
                    data_out <= ram_data_inout;
                end else begin
                    // data[ram_address_out] <= ram_data_inout;
                end
                // ram_en_out <= 1;
                // ram_oe_out <= 1;
                // ram_we_out <= 1;
                // state <= PREP;
            end
        endcase
    end
end

endmodule

//////////SIMULATE////////////

// `include "defines.v"

// module ram_control (
//   input   wire                  clk,
//   input   wire                  rst,
//   input   wire                  enable_in,        // 使能信号
//   input   wire                  readWrite_in,     // 0表示读，1表示写
//   input   wire[`MemAddrBus]     address_in,
//   input   wire[`MemBus]         data_in,
//   input   wire[1:0]             state,
//   output  reg[`MemBus]          data_out,
//   output  reg                   ram_oe_out,
//   output  reg                   ram_we_out,
//   output  reg                   ram_en_out,
//   output  reg[`MemAddrBus]      ram_address_out,
//   inout   wire[`MemBus]         ram_data_inout
// );

// reg[`MemBus] data[0:65536];
// initial $readmemh("src/asm/inst_rom.data", data);
// reg[`MemBus] dataBuffer;
// // reg[1:0] state = 2'b00;
// reg[1:0] PREP = 2'b00, VISIT = 2'b01, SET = 2'b11, HOLD = 2'b10;
// assign ram_data_inout = ((readWrite_in == 0) )? `HighZWord : data_in;

// always @ (negedge clk) begin
//     if (rst == `RstEnable || enable_in == `Disable) begin
//         // state <= PREP;
//         ram_en_out <= 1;
//         ram_oe_out <= 1;
//         ram_we_out <= 1;
//         dataBuffer <= `ZeroWord;
//     end else begin
//         case (state)
//             PREP: begin
//                 if (readWrite_in == `MemRead) begin
//                     ram_en_out <= 1;
//                     ram_oe_out <= 1;
//                     ram_we_out <= 1;
//                 end else begin
//                     ram_en_out <= 1;
//                     ram_oe_out <= 1;
//                     ram_we_out <= 1;
//                 end
//                 // state <= VISIT;
//             end
//             VISIT: begin
//                 ram_address_out <= address_in;
//                 // state <= SET;
//             end
//             SET: begin
//                 if (readWrite_in == `MemRead) begin
//                     ram_en_out <= 0;
//                     ram_oe_out <= 0;
//                     ram_we_out <= 1;
//                     data_out <= data[ram_address_out];
//                 end else begin
//                     ram_en_out <= 0;
//                     ram_oe_out <= 1;
//                     ram_we_out <= 0;
//                     data[ram_address_out] <= ram_data_inout;
//                 end
//                 // state <= HOLD;
//             end
//             HOLD: begin
//                 if (readWrite_in == `MemRead) begin
//                     data_out <= data[ram_address_out];
//                 end else begin
//                     data[ram_address_out] <= ram_data_inout;
//                 end
//                 // ram_en_out <= 1;
//                 // ram_oe_out <= 1;
//                 // ram_we_out <= 1;
//                 // state <= PREP;
//             end
//         endcase
//     end
// end
// endmodule
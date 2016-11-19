`include "defines.v"

// 流水线寄存器if/id
module if_id (
    input   wire                    clk,                // 时钟
    input   wire                    rst,                // 复位

    input   wire[`InstAddrBus]      instAddr_i,         // if段指令地址
    input   wire[`InstBus]          inst_i,             // if段指令数据
    output  reg[`InstAddrBus]       instAddr_o,         // id段指令地址
    output  reg[`InstBus]           inst_o              // id段指令数据
);

    // 将if段指令地址和数据在时钟上升沿传入id段
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			inst_o <= `ZeroWord;
			instAddr_o <= `ZeroWord;
	  end else begin
		  inst_o <= inst_i;
		  instAddr_o <= instAddr_i;
		end
	end

endmodule //if_id

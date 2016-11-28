`include "defines.v"

// 流水线寄存器if/id
module if_id (
    input   wire                    clk,                // 时钟
    input   wire                    rst,                // 复位
	input 	wire[`StallRegBus]		stall,

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
		end else if (stall[1] == `Stop && stall[2] == `NoStop) begin
		  // if暂停，id继续，插入空指令
		  inst_o <= `ZeroWord;
		  instAddr_o <= `ZeroWord;
	  	end else if(stall[1] == `NoStop) begin
		  // if继续
		  inst_o <= inst_i;
		  instAddr_o <= instAddr_i;
		end
		// stall[1] == stall[2] = `Stop，全暂停则保持inst_o instAddr_o不变，无需分离
	end

endmodule //if_id

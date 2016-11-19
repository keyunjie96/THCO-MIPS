`include "defines.v"

// 程序计数器PC
module pc_reg (
    input   wire                    clk,                // 时钟
    input   wire                    rst,                // 复位

    output  reg[`InstAddrBus]       pc,                 // 要读取的指令地址
    output  reg                     ce                  // 指令存储器使能信号
);

    // PC+2或为0
    always @ (posedge clk) begin
        if (ce == `ChipDisable) begin
            pc <= 16'h0000;
        end else begin
            pc <= pc + 2'b10;
        end
    end

    // 同步清零
    always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ce <= `ChipDisable;
		end else begin
			ce <= `ChipEnable;
		end
	end

endmodule // pc_reg

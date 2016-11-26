`include "defines.v"

// 程序计数器PC
module pc_reg (
    input   wire                    clk,                // 时钟
    input   wire                    rst,                // 复位

    //来自stall_control
    input   wire[5:0]               stall,

    //来自ID决定是否跳转的信息
    input   wire                    jump_i,             //是否跳转
    input   wire[`RegBus]           jump_target_addr_i, //跳转地址
    
    //传给id段
    output   reg                    in_delay_slot_o,    //是否在延迟槽

    output  reg[`InstAddrBus]       pc,                 // 要读取的指令地址
    output  reg                     ce                  // 指令存储器使能信号
);
    // PC+2或为0
    always @ (posedge clk) begin
        in_delay_slot_o <= jump_i; //指示下一条指令id段是否处于在延迟槽
        if (ce == `ChipDisable) begin
            pc <= 16'h0000;
            in_delay_slot_o <= `Disable;
        end else if (stall[0] == `NoStop) begin
            if(jump_i == `Enable ) begin
                pc <= jump_target_addr_i; 
            end else begin
                pc <= pc + `PcUnit;
            end
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

`include "defines.v"

module regfile(

	input wire					clk,
	input wire					rst,

	// 执行阶段要写入的地址，主要是BTEQZ需要在ID段进行判断，而上条指令尚在EX段
	input wire 					wEnable_ex_i,
	input wire[`RegAddrBus]		wAddr_ex_i,
	input wire[`RegBus]			wData_ex_i,

	// 写端口
	input wire					wEnable_i,
	input wire[`RegAddrBus]		wAddr_i,
	input wire[`RegBus]			wData_i,

  	// 读端口1
	input wire					rEnable1_i,
	input wire[`RegAddrBus]		rAddr1_i,
	output reg[`RegBus]         rData1_o,

  	// 读端口2
	input wire					rEnable2_i,
	input wire[`RegAddrBus]		rAddr2_i,
	output reg[`RegBus]         rData2_o

);

reg[`RegBus] regs[0:`RegNum-1];	

// 写操作
always @ (posedge clk) begin
  	if (rst == `RstDisable) begin
    	if((wEnable_i == `WriteEnable) && wAddr_i != `RegZero) begin
			regs[wAddr_i] <= wData_i;
		end
	end
	else begin
		regs[0] <= `ZeroWord;
	end
end

// 读端口1
always @ ( * ) begin
	if (rst == `RstEnable) begin
		rData1_o <= `ZeroWord;
	end
	else if (rAddr1_i == `RegZero) begin
		rData1_o <= `ZeroWord;
	end
	else if ((rAddr1_i == wAddr_i) && (wEnable_i == `WriteEnable)
		&& (rEnable1_i == `ReadEnable)) begin
			rData1_o <= wData_i;		// TODO: 验证此处行为，同周期内同时读和写，读出的数是什么？
	end
	else if ((rAddr1_i == wAddr_ex_i) && (wEnable_i == `WriteEnable)
		&& (rEnable1_i == `ReadEnable)) begin
		rData1_o <= wData_ex_i;
	end
	else if (rEnable1_i == `ReadEnable) begin
		rData1_o <= regs[rAddr1_i];
	end
	else begin
		rData1_o <= `ZeroWord;
	end
end

// 读端口2
always @ ( * ) begin
	if (rst == `RstEnable) begin
		rData2_o <= `ZeroWord;
	end
	else if (rAddr2_i == `RegZero) begin
		rData2_o <= `ZeroWord;
	end
	else if ((rAddr2_i == wAddr_i) && (wEnable_i == `WriteEnable)
		&& (rEnable2_i == `ReadEnable)) begin
			rData2_o <= wData_i;
	end
	else if ((rAddr2_i == wAddr_ex_i) && (wEnable_i == `WriteEnable)
		&& (rEnable2_i == `ReadEnable)) begin
		rData2_o <= wData_ex_i;
	end
	else if (rEnable2_i == `ReadEnable) begin
		rData2_o <= regs[rAddr2_i];
	end
	else begin
		rData2_o <= `ZeroWord;
	end
end

endmodule //regfile

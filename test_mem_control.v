`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:   00:22:43 11/27/2016
// Design Name:   mem_control
// Module Name:   E:/Study/xilinx/THCO-MIPS/test_mem_control.v
// Project Name:  THCO-MIPS
// Target Device:
// Tool versions:
// Description:
//
// Verilog Test Fixture created by ISE for module: mem_control
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

`define ZeroWord 16'h0000

module test_mem_control;

	// Inputs
	reg clk;
	reg rst;
	reg[15:0] instAddress_i;
	reg memReadEnable_i;
	reg memWriteEnable_i;
	reg pauseRequest_i;
	reg[15:0] memDataRead_i;
	reg[15:0] memAddress_i;

	// Instantiate the Unit Under Test (UUT)
	mem_control uut (
		.clk(clk),
		.rst(rst),
		.pauseRequest_i(pauseRequest_i),
		.memReadEnable_i(memReadEnable_i),
		.memWriteEnable_i(memWriteEnable_i),
		.instAddress_i(instAddress_i),
		.memDataRead_i(memDataRead_i),
		.memAddress_i(memAddress_i)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		pauseRequest_i = 0;
		instAddress_i = `ZeroWord;

		// Wait 20 ns for global reset to finish
		#20;

		// Add stimulus here
		clk = 1;
		rst = 1;
		// 读指�
		instAddress_i = 16'h00FF;
		memReadEnable_i = 0;
		memWriteEnable_i = 0;
		#10;
		clk = 0;
		memDataRead_i = 16'h000E;
		#10;
		// 读指令和数据
		clk = 1;
		instAddress_i = 16'h000F;
		pauseRequest_i = 1;
		#10;
		clk = 0;
		memDataRead_i = 16'h000C;
		#10;
		// 读指令和数据
		clk = 1;
		pauseRequest_i = 1;
		memReadEnable_i = 1;
		memWriteEnable_i = 0;
		memAddress_i = 16'h0001;
		#10;
		clk = 0;
		memDataRead_i = 16'h0F00;
		#10;
		clk = 1;
		pauseRequest_i = 0;
		#10 $stop;

	end

endmodule

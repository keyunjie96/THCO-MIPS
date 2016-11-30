`include "defines.v"
`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:   14:56:51 11/20/2016
// Design Name:   top
// Module Name:   C:/Users/keyun/Documents/Code/THCO-MIPS/src/test_top.v
// Project Name:  THCO-MIPS
// Target Device:
// Tool versions:
// Description:
//
// Verilog Test Fixture created by ISE for module: top
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module test_top;

	// Inputs
	reg clk;
	reg rst;
	reg clk_choose;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk(clk),
		.rst(rst),
		.clk_choose(clk_choose)
	);

	initial begin
		clk_choose = 1'b0;
		clk = 1'b0;
		forever #2 clk = ~clk;
	end

	initial begin
		rst = `RstEnable;
		#2 rst = `RstDisable;
		#1000 $stop;
	end

endmodule

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

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk(clk), 
		.rst(rst)
	);

	initial begin
		clk = 1'b0;
		forever #10 clk = ~clk;
	end

	initial begin
		rst = `RstEnable;
		#15 rst = `RstDisable;
		#600 $stop;
	end
      
endmodule


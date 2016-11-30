`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:32:01 11/29/2016
// Design Name:   uart
// Module Name:   C:/Users/keyun/Documents/Code/THCO-MIPS-LATEST/test_uart.v
// Project Name:  THCO-MIPS
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: uart
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_uart;

	// Instantiate the Unit Under Test (UUT)
	reg clk;
	reg rst;
	reg goto_read;
	reg goto_write;

	uart uut (
		.clk(clk),
		.rst(rst),
		.goto_read(goto_read),
		.goto_write(goto_write)
	);

	initial begin
		// Initialize Inputs
		clk = 1'b0;
		goto_read = 1'b0;
		goto_write = 1'b1;
		#10
		clk = 1'b1; 
		rst = 1'b0;
		// Wait 100 ns for global reset to finish
		forever #10 clk = ~clk;
		// Add stimulus here
	end
	initial begin
		#15 goto_read = 1'b1;
	end
      
endmodule


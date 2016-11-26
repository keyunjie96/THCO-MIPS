`include "defines.v"

module inst_rom(

	input wire										ce,
	input wire[`InstAddrBus]			addr,
	output reg[`InstBus]					inst

);

	always @ (*) begin
		if (ce == `ChipDisable) begin
			inst = `ZeroWord;
	  end else begin
		  case (addr)
/**instructions**/
          16'h0000: inst = 16'h0169;
          16'h0002: inst = 16'h0210;
          16'h0004: inst = 16'h2141;
          16'h0006: inst = 16'h0221;
          16'h0008: inst = 16'h2241;
          16'h000A: inst = 16'h0220;
          16'h000C: inst = 16'h2141;
          16'h000E: inst = 16'h2441;
          16'h0010: inst = 16'h0B71;
          16'h0012: inst = 16'h0660;
          16'h0014: inst = 16'h0210;
          16'h0016: inst = 16'h2141;
          16'h0018: inst = 16'h2241;

		    default: inst = `ZeroWord;
		  endcase
		end
	end

endmodule

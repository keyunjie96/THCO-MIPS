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

		    default: inst = `ZeroWord;
		  endcase
		end
	end

endmodule

`include "defines.v"

module inst_rom(

	input wire										ce,
	input wire[`InstAddrBus]			addr,
	output reg[`InstBus]					inst

);

	reg[`InstWordBus]  inst_mem[0:`InstMemNum-1];

	// initial $readmemh ( "src/asm/inst_rom.data", inst_mem );

	always @ (addr or ce) begin
		if (ce == `ChipDisable) begin
			inst <= `ZeroWord;
	  end else begin
	  	inst <= {inst_mem[addr[`InstMemNumLog2+1:1]*2+1], inst_mem[addr[`InstMemNumLog2+1:1]*2]};
		// inst[`InstLo] <= inst_mem[addr[`InstMemNumLog2+1:1]*2];//TO DO: ADD OFFSET
	  	// inst[`InstHi] <= inst_mem[addr[`InstMemNumLog2+1:1]*2+1];//虽然文件存储小端序，但顺序读入ROM成为大端序，分开读取是再转换为小端序
		end
	end

endmodule

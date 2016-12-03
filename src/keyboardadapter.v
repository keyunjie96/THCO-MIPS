module KeyboardAdapter(
	input wire clk, rst,
	input wire ps2data, ps2clk,
	input wire DataReceive,
	output wire DataReady,
	// input wire[6:0] query_addr,
	output wire [7:0] ascii_o
	//output wire[3:0] status_debug
);

wire e0;
wire f0;
wire[7:0] raw_data;
// wire[7:0] addr;
reg[127:0] one_hot_key_down = 128'h0;
reg query_res;
wire data_ready;
reg DataReadyReg;
assign DataReady = DataReadyReg & ~query_res;

//assign out = query_res;
// assign led = {addr, 8'd0, query_res};
// assign ascii_o = addr;

// wire[127:0] tmp1;
// wire[127:0] tmp2;

// assign tmp1 = 1<<addr;
// assign tmp2 = 1<<query_addr;
always @(*) begin
	if (rst == 0 || DataReceive == 0) begin
		DataReadyReg = 0;
	end else if (query_res == 1) begin
		DataReadyReg = 1;
	end
end

always @(posedge clk) begin
	if (data_ready == 1) begin
		if (f0 == 1)
			query_res <= 0;
			//one_hot_key_down <= one_hot_key_down & (~tmp1);
		else
			query_res <= 1;
			//one_hot_key_down <= one_hot_key_down | tmp1;
	end else //one_hot_key_down <= one_hot_key_down;
			query_res <= query_res;
end

//always @(*) begin
//	query_res = ((one_hot_key_down & tmp2) == 128'h0);
//end

keyboard keyboard0(
	.clk(clk), .rst(rst),
	.ps2data(ps2data), .ps2clk(ps2clk),
	.data_ready(data_ready),
	.e0_flag(e0),
	.break_flag(f0), 
	.out(raw_data)
);

keyboard2ascii keyboard2ascii0(
	.e0_flag(e0),
	.key(raw_data),
	.ascii(ascii_o)
);

endmodule
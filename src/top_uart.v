`include "defines.v"

module top_ (
    input wire clk,
    // send
    input wire send_ready,
    input wire[`UartRegBus] send_data,
    output wire uart_send,
    output wire send_busy,

    // receive
    input wire uart_receive,
    output wire receive_ready,
    output wire[`UartRegBus] receive_data,
    output wire receive_idle
);

reg clk_half;

always @( posedge clk ) begin
    clk_half <= ~clk_half;
end

async_transmitter send0(
	.clk(clk_half),
	.TxD_start(receive_ready),
	.TxD_data(send_data),
    .TxD(uart_send),
	.TxD_busy(send_busy)
);

async_receiver receive0(
    .clk(clk_half),
    .RxD(uart_receive),
    .RxD_data_ready(receive_ready),
    .RxD_data(receive_data),
    .RxD_idle(receive_idle)
);

endmodule // top

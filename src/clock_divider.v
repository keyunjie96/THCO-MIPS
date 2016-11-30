`include "defines.v"

module clock_divider (
    input wire clk,
    input wire rst,
    output reg[1:0] state,
    output reg clk_fast,
    output reg clk_slow
);

// reg[1:0] state = 2'b00;
reg[1:0] ONE = 2'b00, TWO = 2'b01, THREE = 2'b11, FOUR = 2'b10;

always @ ( clk ) begin
    if (rst == `RstEnable) begin
        clk_fast <= 0;
    end else begin
        clk_fast <= clk;
    end
end

always @ (posedge clk) begin
    if (rst == `RstEnable) begin
        clk_slow <= 0;
        state <= ONE;
    end else begin
        case (state)
            ONE: begin
                clk_slow <= 1;
                state <= TWO;
            end
            TWO: begin
                clk_slow <= 1;
                state <= THREE;
            end
            THREE: begin
                clk_slow <= 0;
                state <= FOUR;
            end
            FOUR: begin
                clk_slow <= 0;
                state <= ONE;
            end
            default: state <= ONE;
        endcase
    end
end

endmodule // clock_divider

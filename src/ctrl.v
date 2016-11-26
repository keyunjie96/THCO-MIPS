`include "defines.v"

module ctrl (
  input wire                rst,
  input wire                stall_request_from_id,
  input wire                stall_request_from_mem,
  output reg[`StallRegBus]  stallCtrl
);

always @ ( * ) begin
  if (rst == `RstEnable) begin
    stallCtrl <= `StallDisable;
  end
  else if (stall_request_from_mem == `Enable) begin
    stallCtrl <= 6'b001111;
  end
  else if (stall_request_from_id == `Enable) begin
    stallCtrl <= 6'b000111;
  end
  else begin
    stallCtrl <= `StallDisable;
  end
end

endmodule // ex_mem

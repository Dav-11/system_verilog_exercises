// from: https://www.siliconcrafters.com/post/fixed-priority-arbiter
//
// Linear prefix (ripple) arbiter

module fixed_pri_arbiter_linear #(
    parameter N = 32
) (
    // input logic clk,
    // input logic rst_n,

    input  logic [N-1:0] req,
    output logic [N-1:0] gnt
);

  // ====================================================
  // Internal signals
  // ====================================================

  logic [N-1:0] higher_pri_req;

  // ======================================
  // Combinational logic
  // ======================================

  assign higher_pri_req[0] = 1'b0;  // LSB has the highest priority

  generate
    for (genvar i = 0; i < N - 1; i++) begin : gen_prefix
      assign higher_pri_req[i+1] = higher_pri_req[i] | req[i];
    end
  endgenerate

  assign gnt = req & ~higher_pri_req;

endmodule

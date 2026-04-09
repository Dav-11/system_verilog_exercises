module rr_arbiter_linear_scan #(
    parameter int N = 32
) (
    input logic clk,
    input logic rst_n,

    input  logic [N-1:0] req,
    output logic [N-1:0] gnt   // one-hot
);

  // ====================================================
  // Internal signals
  // ====================================================

  logic [$clog2(N)-1:0] last_grant;
  logic [$clog2(N)-1:0] grant_idx;
  logic                 grant_found;


  // ======================================
  // Sequential logic
  // ======================================

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin

      last_grant <= '0;
    end else if (grant_found) begin

      // Update pointer only if a grant happened
      last_grant <= grant_idx;
    end
  end

  // ======================================
  // Combinational logic
  // ======================================

  always_comb begin
    gnt         = '0;
    grant_idx   = last_grant;
    grant_found = 1'b0;

    // Scan all possible requesters
    for (int i = 0; i < N; i++) begin

      int idx;
      idx = (last_grant + 1 + i) % N;

      if (!grant_found && req[idx]) begin
        gnt[idx]    = 1'b1;
        grant_idx   = idx[$clog2(N)-1:0];
        grant_found = 1'b1;
      end
    end
  end

endmodule : rr_arbiter_linear_scan

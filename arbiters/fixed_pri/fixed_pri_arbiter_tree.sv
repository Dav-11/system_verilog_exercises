
// Tree arbiter

module fixed_pri_arbiter_tree #(
    parameter int N = 32,
    localparam int LEVELS = $clog2(N)
) (
    input  logic [N-1:0] req,
    output logic [N-1:0] gnt
);

  // -----------------------------
  // Internal tree signals
  // -----------------------------
  logic [N-1:0] req_tree[0:LEVELS];
  logic [N-1:0] gnt_tree[0:LEVELS];

  // -----------------------------
  // Level 0 = inputs
  // -----------------------------
  assign req_tree[0] = req;

  // -----------------------------
  // UPWARD PASS (build winners)
  // -----------------------------
  genvar l, i;

  generate
    for (l = 0; l < LEVELS; l++) begin : LEVEL_UP
      for (i = 0; i < (N >> (l + 1)); i++) begin : NODE

        wire [1:0] pair_req;

        assign pair_req[0] = req_tree[l][2*i];
        assign pair_req[1] = req_tree[l][2*i+1];

        // winner propagates upward
        assign req_tree[l+1][i] = |pair_req;

        // store local grant decision
        assign gnt_tree[l][2*i] = pair_req[0];
        assign gnt_tree[l][2*i+1] = ~pair_req[0] & pair_req[1];

      end
    end
  endgenerate

  // -----------------------------
  // ROOT (only one survives)
  // -----------------------------
  // At top: only one request survives → implicit

  // -----------------------------
  // DOWNWARD PASS (mask losers)
  // -----------------------------
  // Start from top and propagate enables

  logic [N-1:0] enable_tree[0:LEVELS];

  assign enable_tree[LEVELS][0] = 1'b1;

  generate
    for (l = LEVELS - 1; l >= 0; l--) begin : LEVEL_DOWN
      for (i = 0; i < (N >> (l + 1)); i++) begin : NODE

        wire en = enable_tree[l+1][i];

        assign enable_tree[l][2*i]   = en & gnt_tree[l][2*i];
        assign enable_tree[l][2*i+1] = en & gnt_tree[l][2*i+1];

      end
    end
  endgenerate

  // -----------------------------
  // Final grants
  // -----------------------------
  assign gnt = enable_tree[0];

endmodule

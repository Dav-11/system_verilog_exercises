module axi4_mux_w_arb #(
    parameter int RR_PRIO_NUMBER = 4,
    parameter int FIXED_PRIO_NUMBER = 1,
    localparam int INPUT_NUMBER = RR_PRIO_NUMBER + FIXED_PRIO_NUMBER
) (
    input logic clk,
    input logic rst_n,

    input logic [INPUT_NUMBER-1:0] in_aw_valid,

    input logic out_aw_ready,
    input logic out_b_valid,
    input logic out_b_ready,

    output logic [INPUT_NUMBER-1:0] sel
);

  // ====================================================
  // States
  // ====================================================

  typedef enum logic [1:0] {
    IDLE,
    BUSY
  } state_t;

  // ====================================================
  // Registers
  // ====================================================

  state_t state_r, state_n;
  logic [INPUT_NUMBER-1:0] sel_r, sel_n;

  // ====================================================
  // Internal signals
  // ====================================================

  logic [RR_PRIO_NUMBER-1:0] rr_req, rr_gnt;
  logic [FIXED_PRIO_NUMBER-1:0] fixed_req, fixed_gnt;

  logic rr_has_req, fixed_has_req;

  logic [INPUT_NUMBER-1:0] grant_comb;

  // ======================================
  // Sequential logic
  // ======================================

  always_ff @(posedge clk) begin
    if (!rst_n) begin

      state_r <= IDLE;
      sel_r   <= '0;

    end else begin

      state_r <= state_n;
      sel_r   <= sel_n;
    end
  end

  // ======================================
  // Combinational logic
  // ======================================

  // internal signals
  // TODO: check if out_aw_ready is necessary or remove
  assign {rr_req, fixed_req} = in_aw_valid & {INPUT_NUMBER{out_aw_ready}};

  assign rr_has_req = |rr_req;
  assign fixed_has_req = |fixed_req;

  // output
  assign sel = sel_r;

  always_comb begin

    // ======================================
    // DEFAULTS
    // ======================================
    state_n = state_r;
    sel_n   = '0;

    unique case (state_r)

      IDLE: begin

        // check if rr has grant -> check if fixed has grant -> default noone
        // assumes both fixed and RR produce gnt in 1 clock cycle
        grant_comb = rr_has_req ? {rr_gnt, {FIXED_PRIO_NUMBER{1'b0}}} :
          fixed_has_req ? {{RR_PRIO_NUMBER{1'b0}}, fixed_gnt} :
          '0;

        // if someone is granted => output + change state
        if (grant_comb != '0) begin
          sel_n   = grant_comb;
          state_n = BUSY;
        end
      end

      BUSY: begin

        if (out_b_valid && out_b_ready) begin

          // back to idle (tx is completed)
          state_n = IDLE;
        end else begin

          // keep asserting conn
          sel_n = sel_r;
        end
      end
    endcase
  end

  // ====================================================
  // External modules
  // ====================================================

  fixed_pri_arbiter_linear #(
      .N(FIXED_PRIO_NUMBER)
  ) fixed_pri_arbiter (

      .req(fixed_req),
      .gnt(fixed_gnt)
  );

  rr_arbiter_linear_scan #(
      .N(RR_PRIO_NUMBER)
  ) rr_arbiter (
      .clk  (clk),
      .rst_n(rst_n),

      .req(rr_req),
      .gnt(rr_gnt)
  );

endmodule : axi4_mux_w_arb

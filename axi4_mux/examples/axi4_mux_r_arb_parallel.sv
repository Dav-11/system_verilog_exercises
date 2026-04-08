module axi4_mux_r_arb_parallel #(
    parameter  int RR_PRIO_NUMBER    = 4,
    parameter  int FIXED_PRIO_NUMBER = 1,
    localparam int INPUT_NUMBER      = RR_PRIO_NUMBER + FIXED_PRIO_NUMBER
) (
    input logic clk,
    input logic rst_n,

    input logic [INPUT_NUMBER-1:0] in_ar_valid,

    input logic out_r_valid,
    input logic out_r_ready,
    input logic out_r_last,

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

  // RR pointer register
  logic [$clog2(RR_PRIO_NUMBER)-1:0] rr_ptr_r, rr_ptr_n;

  logic [RR_PRIO_NUMBER-1:0] rr_req;
  logic [RR_PRIO_NUMBER-1:0] rr_grant_masked;
  logic [RR_PRIO_NUMBER-1:0] rr_grant_plain;
  logic [FIXED_PRIO_NUMBER-1:0] fixed_req;
  logic [FIXED_PRIO_NUMBER-1:0] fixed_grant;

  // ====================================================
  // Sequential logic
  // ====================================================

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      state_r  <= IDLE;
      sel_r    <= '0;
      rr_ptr_r <= '0;
    end else begin
      state_r  <= state_n;
      sel_r    <= sel_n;
      rr_ptr_r <= rr_ptr_n;
    end
  end

  // ====================================================
  // Combinational logic
  // ====================================================


  // output
  assign sel = sel_r;

  // split request groups
  assign rr_req    = in_ar_valid[RR_PRIO_NUMBER-1:0];
  assign fixed_req = in_ar_valid[INPUT_NUMBER-1:RR_PRIO_NUMBER];

  // ----------------------------------------------------
  // Priority encoder function (fully combinational)
  // ----------------------------------------------------
  function automatic logic [31:0] priority_enc(input logic [31:0] req, input int width);
    logic [31:0] prefix;
    logic [31:0] grant;
    begin
      prefix[0] = 1'b0;
      for (int i = 1; i < width; i++) begin
        prefix[i] = |(req[i-1:0]);
      end
      grant = req & ~prefix;
      return grant;
    end
  endfunction

  // ----------------------------------------------------
  // Round-robin grant (parallel, masked)
  // ----------------------------------------------------
  logic [RR_PRIO_NUMBER-1:0] rr_mask;
  logic any_rr_masked;

  // mask after rr_ptr
  generate
    genvar i;
    for (i = 0; i < RR_PRIO_NUMBER; i++) begin : rr_mask_gen
      assign rr_mask[i] = (i >= rr_ptr_r) ? 1'b1 : 1'b0;
    end
  endgenerate

  // apply mask
  assign any_rr_masked   = |(rr_req & rr_mask);
  assign rr_grant_masked = priority_enc(rr_req & rr_mask, RR_PRIO_NUMBER) [RR_PRIO_NUMBER-1:0];
  assign rr_grant_plain  = priority_enc(rr_req, RR_PRIO_NUMBER) [RR_PRIO_NUMBER-1:0];

  logic [RR_PRIO_NUMBER-1:0] rr_final_grant;
  assign rr_final_grant = any_rr_masked ? rr_grant_masked : rr_grant_plain;

  // ----------------------------------------------------
  // Fixed-priority grant (parallel)
  // ----------------------------------------------------
  assign fixed_grant = priority_enc(fixed_req, FIXED_PRIO_NUMBER) [FIXED_PRIO_NUMBER-1:0];

  // ----------------------------------------------------
  // State machine combinational
  // ----------------------------------------------------
  always_comb begin
    state_n  = state_r;
    sel_n    = sel_r;
    rr_ptr_n = rr_ptr_r;

    unique case (state_r)
      IDLE: begin
        sel_n = '0;
        logic granted = 0;

        // ---------------- Round-robin
        for (int i = 0; i < RR_PRIO_NUMBER; i++) begin
          if (!granted && rr_final_grant[i]) begin
            sel_n[i] = 1'b1;
            rr_ptr_n = (i + 1) % RR_PRIO_NUMBER;
            granted  = 1;
          end
        end

        // ---------------- Fixed-priority fallback
        for (int i = 0; i < FIXED_PRIO_NUMBER; i++) begin
          if (!granted && fixed_grant[i]) begin
            sel_n[RR_PRIO_NUMBER+i] = 1'b1;
            granted = 1;
          end
        end

        if (granted) state_n = BUSY;
      end

      BUSY: begin
        sel_n = sel_r;
        if (out_r_valid && out_r_ready && out_r_last) begin
          sel_n   = '0;
          state_n = IDLE;
        end
      end
    endcase
  end

endmodule

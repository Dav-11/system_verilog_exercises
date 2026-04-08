module axi4_mux_r_arb #(
    parameter int RR_PRIO_NUMBER = 4,
    parameter int FIXED_PRIO_NUMBER = 1,
    localparam int INPUT_NUMBER = RR_PRIO_NUMBER + FIXED_PRIO_NUMBER
) (
    input logic clk,
    input logic rst_n,

    input logic [INPUT_NUMBER-1:0] in_ar_valid,


    input logic out_r_last,
    input logic out_r_valid,
    input logic out_r_ready,

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

  logic [$clog2(RR_PRIO_NUMBER)-1:0] rr_ptr_r, rr_ptr_n;


  // ======================================
  // Sequential logic
  // ======================================

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

  // ======================================
  // Combinational logic
  // ======================================

  // output
  assign sel = sel_r;

  always_comb begin

    // ======================================
    // DEFAULTS
    // ======================================
    state_n  = state_r;
    sel_n    = '0;
    rr_ptr_n = rr_ptr_r;

    unique case (state_r)

      IDLE: begin

        logic granted = 0;

        // compute next sel (one-hot encoding)

        // ------------------------------
        // 1. ROUND-ROBIN
        // ------------------------------
        // check if any requests (using in_ar_valid) from first RR_PRIO_NUMBER -> chose using RR from them

        for (int i = 0; i < RR_PRIO_NUMBER; i++) begin
          int idx = (rr_ptr_r + i) % RR_PRIO_NUMBER;

          if (!granted && in_ar_valid[idx]) begin
            sel_n[idx] = 1'b1;
            rr_ptr_n   = (idx + 1) % RR_PRIO_NUMBER;
            granted    = 1;
          end
        end

        // ------------------------------
        // 2. FIXED PRIORITY (fallback)
        // ------------------------------
        // use FIXED PRIORITY for last FIXED_PRIO_NUMBER bits if no rr available

        if (!granted) begin
          for (int i = RR_PRIO_NUMBER; i < INPUT_NUMBER; i++) begin
            if (!granted && in_ar_valid[i]) begin
              sel_n[i] = 1'b1;
              granted  = 1;
            end
          end
        end

        // ------------------------------
        // 3. State transition
        // ------------------------------
        // if no requests -> stay in IDLE

        if (granted) begin
          state_n = BUSY;
        end
      end

      BUSY: begin

        if (out_r_valid && out_r_ready && out_r_last) begin

          // back to idle (tx is completed)
          state_n = IDLE;
        end else begin

          // keep asserting conn
          sel_n = sel_r;
        end
      end
    endcase
  end

endmodule : axi4_mux_r_arb

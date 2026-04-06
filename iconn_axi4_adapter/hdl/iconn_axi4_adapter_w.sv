module iconn_axi4_adapter_w #(
    parameter int AW = 32,
    parameter int ICONN_DW = 64,
    parameter int AXI_ID_WIDTH = 8,
    parameter int AXI_DATA_WIDTH = 256,
    parameter logic [AXI_ID_WIDTH-1:0] ID = '1
) (
    input logic clk,
    input logic rst_n,

    // ================= ICONN SIDE =================

    input  logic [      AW-1:0] addr,
    input  logic                enable,
    output logic [ICONN_DW-1:0] data,
    output logic                ack,

    // ================= AXI MASTER SIDE =================

    // Write address
    output logic [AXI_ID_WIDTH-1:0] aw_id,
    output logic [          AW-1:0] aw_addr,
    output logic [             7:0] aw_len,
    output logic [             2:0] aw_size,
    output logic [             1:0] aw_burst,
    output logic                    aw_valid,
    input  logic                    aw_ready,

    // Write data
    output logic [    AXI_DATA_WIDTH-1:0] w_data,
    output logic [(AXI_DATA_WIDTH/8)-1:0] w_strb,
    output logic                          w_last,
    output logic                          w_valid,
    input  logic                          w_ready,

    // Read response
    input  logic [AXI_ID_WIDTH-1:0] b_id,
    input  logic [             1:0] b_resp,
    input  logic                    b_valid,
    output logic                    b_ready
);

  // ====================================================
  // Compile-time constraint
  // ====================================================

  initial begin
    if (ICONN_DW > AXI_DATA_WIDTH)
      $error("iconn_axi4_adapter_r: ICONN_DW must be <= AXI_DATA_WIDTH");
  end

  // ====================================================
  // Derived constants
  // ====================================================

  localparam int ICONN_BYTES = ICONN_DW / 8;
  localparam int AXI_BYTES = AXI_DATA_WIDTH / 8;

  localparam int ICONN_BYTE_LSB = $clog2(ICONN_BYTES);
  localparam int AXI_BYTE_LSB = $clog2(AXI_BYTES);

  localparam int LANE_BITS = AXI_BYTE_LSB - ICONN_BYTE_LSB;

  // AXI size = log2(bytes per beat)
  localparam logic [2:0] AXI_SIZE = $clog2(AXI_BYTES);

  // Single beat
  localparam logic [7:0] AXI_BEAT_NUMBER = 8'd0;

  // ====================================================
  // States
  // ====================================================

  typedef enum logic [1:0] {
    IDLE,
    ADDRESS_WRITE,
    DATA_WRITE,
    RESPONSE_READ,
    ERROR
  } state_t;

  // ====================================================
  // Registers
  // ====================================================

  state_t state_r, state_n;
  logic [LANE_BITS-1:0] lane;

  // output
  logic [AXI_ID_WIDTH-1:0] aw_id_r, aw_id_n;
  logic [AW-1:0] aw_addr_r, aw_addr_n;
  logic [7:0] aw_len_r, aw_len_n;
  logic [2:0] aw_size_r, aw_size_n;
  logic [1:0] aw_burst_r, aw_burst_n;
  logic aw_valid_r, aw_valid_n;

  logic [AXI_DATA_WIDTH-1:0] w_data_r, w_data_n;
  logic [(AXI_DATA_WIDTH/8)-1:0] w_strb_r, w_strb_n;
  logic w_last_r, w_last_n;
  logic w_valid_r, w_valid_n;

  logic b_ready_r, b_ready_n;

  logic ack_r, ack_n;


  // ======================================
  // Sequential logic
  // ======================================

  always_ff @(posedge clk) begin
    if (!rst_n) begin

      state_r    <= IDLE;

      aw_id_r    <= '0;
      aw_addr_r  <= '0;
      aw_len_r   <= '0;
      aw_size_r  <= '0;
      aw_burst_r <= '0;
      aw_valid_r <= '0;

      w_data_r   <= '0;
      w_strb_r   <= '0;
      w_last_r   <= '0;
      w_valid_r  <= '0;

      b_ready_r  <= '0;

      ack_r      <= '0;

    end else begin

      state_r    <= state_n;

      aw_id_r    <= aw_id_n;
      aw_addr_r  <= aw_addr_n;
      aw_len_r   <= aw_len_n;
      aw_size_r  <= aw_size_n;
      aw_burst_r <= aw_burst_n;
      aw_valid_r <= aw_valid_n;

      w_data_r   <= w_data_n;
      w_strb_r   <= w_strb_n;
      w_last_r   <= w_last_n;
      w_valid_r  <= w_valid_n;

      b_ready_r  <= b_ready_n;

      ack_r      <= ack_n;
    end
  end

  // ======================================
  // Combinational logic
  // ======================================

  always_comb begin

    // ======================================
    // DEFAULTS
    // ======================================

    if (LANE_BITS > 0) begin
      lane = addr[AXI_BYTE_LSB-1:CPU_BYTE_LSB];
    end else begin
      lane = '0;
    end

    state_n = state_r;

    aw_id_n = '0;
    aw_addr_n = '0;
    aw_len_n = '0;
    aw_size_n = '0;
    aw_burst_n = 2'b01;  // INCR
    aw_valid_n = '0;

    w_data_n = '0;
    w_strb_n = '0;
    w_last_n = '0;
    w_valid_n = '0;

    b_ready_n = '0;

    unique case (state_r)

      IDLE: begin
        if (enable) begin

          // next state
          state_n    = ADDRESS_READ;

          // start asserting output
          aw_id_n    = ID;

          // ask for address aligned with AXI_WIDTH that contains required address
          // needs lane signal to extract required word
          aw_addr_n  = {addr_r[AW-1:AXI_BYTE_LSB], {AXI_BYTE_LSB{1'b0}}};
          aw_len_n   = AXI_BEAT_NUMBER;
          aw_size_n  = AXI_SIZE;
          aw_valid_n = 1'b1;
        end
      end

      ADDRESS_WRITE: begin

        if (aw_ready) begin

          state_n = DATA_WRITE;

          // start asserting W DATA
          w_data_n[lane*CPU_DW+CPU_DW-1-:CPU_DW] = data;
          w_strb_n[lane*CPU_BYTES+CPU_BYTES-1-:CPU_BYTES] = '1; // no sel signal in input => all word is selected
          w_last_n = 1'b1;  // always 1 beat
          w_valid_n = 1'b1;

        end else begin

          // keep asserting output
          aw_id_n    = aw_id_r;
          aw_addr_n  = aw_addr_r;
          aw_len_n   = aw_len_r;
          aw_size_n  = aw_size_r;
          aw_valid_n = aw_valid_r;
        end
      end

      DATA_WRITE: begin

        if (w_ready) begin

          state_n   = RESPONSE_READ;
          b_ready_n = 1'b1;
        end else begin

          // keep asserting output
          w_data_n  = w_data_r;
          w_strb_n  = w_strb_r;
          w_last_n  = w_last_r;
          w_valid_n = w_valid_r;
        end
      end

      RESPONSE_READ: begin

        if (b_valid) begin

          if (b_resp == 2'b00 || b_resp == 2'b01) begin

            state_n = IDLE;
            ack_n   = 1'b1;
          end else begin

            state_n = ERROR;
          end
        end else begin

          // keep asserting output
          b_ready_n = b_ready_r;
        end
      end

      ERROR: begin
        // blackhole state
      end

    endcase
  end

endmodule : iconn_axi4_adapter_r

module iconn_axi4_adapter_r #(
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

    // Read address
    output logic [AXI_ID_WIDTH-1:0] ar_id,
    output logic [          AW-1:0] ar_addr,
    output logic [             7:0] ar_len,
    output logic [             2:0] ar_size,
    output logic [             1:0] ar_burst,
    output logic                    ar_valid,
    input  logic                    ar_ready,

    // Read data
    input  logic [  AXI_ID_WIDTH-1:0] r_id,
    input  logic [AXI_DATA_WIDTH-1:0] r_data,
    input  logic [               1:0] r_resp,
    input  logic                      r_last,
    input  logic                      r_valid,
    output logic                      r_ready
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
    ADDRESS_READ,
    DATA_READ,
    ERROR
  } state_t;

  // ====================================================
  // Registers
  // ====================================================

  state_t state_r, state_n;
  logic [LANE_BITS-1:0] lane;

  // output
  logic [AXI_ID_WIDTH-1:0] ar_id_r, ar_id_n;
  logic [AW-1:0] ar_addr_r, ar_addr_n;
  logic [7:0] ar_len_r, ar_len_n;
  logic [2:0] ar_size_r, ar_size_n;
  logic [1:0] ar_burst_r, ar_burst_n;
  logic ar_valid_r, ar_valid_n;

  logic r_ready_r, r_ready_n;

  logic [ICONN_DW-1:0] data_r, data_n;
  logic ack_r, ack_n;


  // ======================================
  // Sequential logic
  // ======================================

  always_ff @(posedge clk) begin
    if (!rst_n) begin

      state_r    <= IDLE;

      ar_id_r    <= '0;
      ar_addr_r  <= '0;
      ar_len_r   <= '0;
      ar_size_r  <= '0;
      ar_burst_r <= '0;
      ar_valid_r <= '0;

      r_ready_r  <= '0;

      data_r     <= '0;
      ack_r      <= '0;

    end else begin

      state_r    <= state_n;

      ar_id_r    <= ar_id_n;
      ar_addr_r  <= ar_addr_n;
      ar_len_r   <= ar_len_n;
      ar_size_r  <= ar_size_n;
      ar_burst_r <= ar_burst_n;
      ar_valid_r <= ar_valid_n;

      r_ready_r  <= r_ready_n;

      data_r     <= data_n;
      ack_r      <= ack_n;

    end
  end

  // ======================================
  // Combinational logic
  // ======================================

  // output

  assign ar_id    = ar_id_r;
  assign ar_addr  = ar_addr_r;
  assign ar_len   = ar_len_r;
  assign ar_size  = ar_size_r;
  assign ar_burst = ar_burst_r;
  assign ar_valid = ar_valid_r;

  assign r_ready  = r_ready_r;

  assign ack      = ack_r;
  assign data     = data_r;

  always_comb begin

    // ======================================
    // DEFAULTS
    // ======================================

    if (LANE_BITS > 0) begin
      lane = addr[AXI_BYTE_LSB-1:ICONN_BYTE_LSB];
    end else begin
      lane = '0;
    end

    state_n    = state_r;

    ar_id_n    = '0;
    ar_addr_n  = '0;
    ar_len_n   = '0;
    ar_size_n  = '0;
    ar_burst_n = 2'b01;  // INCR
    ar_valid_n = '0;

    r_ready_n  = '0;

    ack_n      = '0;
    data_n     = '0;

    unique case (state_r)

      IDLE: begin
        if (enable) begin

          // next state
          state_n    = ADDRESS_READ;

          // start asserting output

          ar_id_n    = ID;

          // ask for address aligned with AXI_WIDTH that contains required address
          // needs lane signal to extract required word
          ar_addr_n  = {addr[AW-1:AXI_BYTE_LSB], {AXI_BYTE_LSB{1'b0}}};
          ar_len_n   = AXI_BEAT_NUMBER;
          ar_size_n  = AXI_SIZE;
          ar_valid_n = 1'b1;
        end
      end

      ADDRESS_READ: begin

        if (ar_ready) begin

          state_n   = DATA_READ;
          r_ready_n = 1'b1;
        end else begin

          // keep asserting output
          ar_id_n    = ar_id_r;
          ar_addr_n  = ar_addr_r;
          ar_len_n   = ar_len_r;
          ar_size_n  = ar_size_r;
          ar_valid_n = ar_valid_r;

        end
      end

      DATA_READ: begin

        if (r_valid && r_last) begin

          if (r_resp == 2'b00 || r_resp == 2'b01) begin

            state_n = IDLE;

            // output read word
            data_n  = r_data[lane*ICONN_DW+ICONN_DW-1-:ICONN_DW];
            ack_n   = 1'b1;

          end else begin
            state_n = ERROR;
          end

        end else begin

          // keep asserting output
          r_ready_n = r_ready_r;
        end

      end

      ERROR: begin
        // blackhole state
      end

    endcase
  end

endmodule : iconn_axi4_adapter_r

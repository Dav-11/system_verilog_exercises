module iconn_axi4_adapter #(
    parameter int AW = 32,
    parameter int ICONN_DW = 64,
    parameter int AXI_ID_WIDTH = 8,
    parameter int AXI_DATA_WIDTH = 256
) (
    input logic clk,
    input logic rst_n,

    // ================= ICONN SIDE =================

    input  logic [      AW-1:0] r_addr,
    output logic [ICONN_DW-1:0] r_data,
    input  logic                r_cyc,
    output logic                r_ack,

    input  logic [      AW-1:0] w_addr,
    input  logic [ICONN_DW-1:0] w_data,
    input  logic                w_cyc,
    output logic                w_ack,

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

    // Write response
    input  logic [AXI_ID_WIDTH-1:0] b_id,
    input  logic [             1:0] b_resp,
    input  logic                    b_valid,
    output logic                    b_ready,

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
    if (ICONN_DW > AXI_DATA_WIDTH) $error("iconn_axi4_adapter: ICONN_DW must be <= AXI_DATA_WIDTH");
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

  typedef enum logic [2:0] {
    IDLE,
    WRITE_ADDR,
    WRITE_DATA,
    WRITE_RESP,
    READ_ADDR,
    READ_DATA,
    ERROR
  } state_t;

  // ====================================================
  // Registers
  // ====================================================

  state_t state_r, state_n;

  logic [LANE_BITS-1:0] lane;

endmodule : iconn_axi4_adapter

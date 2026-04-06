module iconn_axi4_adapter #(
    parameter int AW = 32,
    parameter int ICONN_DW = 64,
    parameter int AXI_ID_WIDTH = 8,
    parameter int AXI_DATA_WIDTH = 256
) (
    input logic clk,
    input logic rst_n,

    // ================= ICONN SIDE =================

    input  logic [      AW-1:0] raddr,
    output logic [ICONN_DW-1:0] rdata,
    input  logic                rcyc,
    output logic                rack,

    input  logic [      AW-1:0] waddr,
    input  logic [ICONN_DW-1:0] wdata,
    input  logic                wcyc,
    output logic                wack,

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
  // Modules
  // ====================================================

  iconn_axi4_adapter_r #(
      .AW(AW),
      .ICONN_DW(ICONN_DW),
      .AXI_ID_WIDTH(AXI_ID_WIDTH),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
  ) fsm_r (
      .clk  (clk),
      .rst_n(rst_n),

      .addr(raddr),
      .data(rdata),
      .enable(rcyc),
      .ack(rack),

      .ar_id(ar_id),
      .ar_addr(ar_addr),
      .ar_len(ar_len),
      .ar_size(ar_size),
      .ar_burst(ar_burst),
      .ar_valid(ar_valid),
      .ar_ready(ar_ready),

      .r_id(r_id),
      .r_data(r_data),
      .r_resp(r_resp),
      .r_last(r_last),
      .r_valid(r_valid),
      .r_ready(r_ready)
  );

  iconn_axi4_adapter_w #(
      .AW(AW),
      .ICONN_DW(ICONN_DW),
      .AXI_ID_WIDTH(AXI_ID_WIDTH),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
  ) fsm_w (
      .clk  (clk),
      .rst_n(rst_n),

      .addr(waddr),
      .enable(wcyc),
      .data(wdata),
      .ack(wack),

      .aw_id(aw_id),
      .aw_addr(aw_addr),
      .aw_len(aw_len),
      .aw_size(aw_size),
      .aw_burst(aw_burst),
      .aw_valid(aw_valid),
      .aw_ready(aw_ready),

      .w_data (w_data),
      .w_strb (w_strb),
      .w_last (w_last),
      .w_valid(w_valid),
      .w_ready(w_ready),

      .b_id(b_id),
      .b_resp(b_resp),
      .b_valid(b_valid),
      .b_ready(b_ready)
  );

endmodule : iconn_axi4_adapter

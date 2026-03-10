`timescale 1ns / 1ps

module tb_cpu_axi4_adapter;

  localparam int AW = 32;
  localparam int DW = 64;
  localparam int AXI_ID_WIDTH = 8;
  localparam int AXI_DATA_WIDTH = 256;

  // ============ DUT signals ============
  logic                          clk;
  logic                          rst;

  logic                          req;
  logic                          we;
  logic [                AW-1:0] addr;
  logic [                DW-1:0] wdata;
  logic [            (DW/8)-1:0] sel;

  logic [                DW-1:0] rdata;
  logic                          ack;

  // ============ AXI MASTER SIDE ============

  logic [      AXI_ID_WIDTH-1:0] aw_id;
  logic [                AW-1:0] aw_addr;
  logic [                   7:0] aw_len;  // beats = AWLEN + 1
  logic [                   2:0] aw_size;
  logic [                   1:0] aw_burst;  // 01 = INCR, 10 = WRAP, 00 = FIXED
  logic                          aw_valid;
  logic                          aw_ready;

  logic [      AXI_ID_WIDTH-1:0] w_id;
  logic [    AXI_DATA_WIDTH-1:0] w_data;
  logic [(AXI_DATA_WIDTH/8)-1:0] w_strb;
  logic                          w_last;
  logic                          w_valid;
  logic                          w_ready;

  logic [      AXI_ID_WIDTH-1:0] b_id;
  logic [                   1:0] b_resp;
  logic                          b_valid;
  logic                          b_ready;

  logic [      AXI_ID_WIDTH-1:0] ar_id;
  logic [                AW-1:0] ar_addr;
  logic [                   7:0] ar_len;
  //   logic [                   2:0] ar_size;
  logic [                   1:0] ar_burst;
  logic                          ar_valid;
  logic                          ar_ready;

  logic [      AXI_ID_WIDTH-1:0] r_id;
  logic [    AXI_DATA_WIDTH-1:0] r_data;
  logic [                   1:0] r_resp;
  logic                          r_last;
  logic                          r_valid;
  logic                          r_ready;

  // ================= Instantiate DUT =================

  cpu_axi4_adapter #(
      .AW(AW),
      .DW(DW),
      .AXI_ID_WIDTH(AXI_ID_WIDTH),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
  ) dut (
      .clk  (clk),
      .rst_n(!rst),

      // ======== CPU IN ===========

      .req(req),
      .we(we),
      .addr(addr),
      .wdata(wdata),
      .sel(sel),

      .rdata(rdata),
      .ack  (ack),

      // ======== AXI 4 OUT ===========

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
      .b_ready(b_ready),

      .ar_id(ar_id),
      .ar_addr(ar_addr),
      .ar_len(ar_len),
      // .ar_size(ar_size), 
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

  axi3_hbm_channel_mock #(
      .AW(AW),
      .DELAY_W(1),
      .DELAY_R(1),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
  ) hbm (

      .clk  (clk),
      .rst_n(!rst),

      // ======== AXI 4 IN ===========

      .aw_id(aw_id),
      .aw_addr(aw_addr),
      .aw_len(aw_len),
      .aw_size(aw_size),
      .aw_burst(aw_burst),
      .aw_valid(aw_valid),
      .aw_ready(aw_ready),

      .w_id(w_id),
      .w_data(w_data),
      .w_strb(w_strb),
      .w_last(w_last),
      .w_valid(w_valid),
      .w_ready(w_ready),

      .b_id(b_id),
      .b_resp(b_resp),
      .b_valid(b_valid),
      .b_ready(b_ready),

      .ar_id(ar_id),
      .ar_addr(ar_addr),
      .ar_len(ar_len),
      // .ar_size(ar_size), 
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

  always #5 clk = ~clk;

  initial begin

    // reset
    clk <= 0;
    rst <= 1;

    // write to addr A


    // read from addr A

  end

endmodule

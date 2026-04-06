timeunit 1ns; timeprecision 1ps;

module tb_iconn_axi4_adapter;

  // Parameters
  localparam int AW = 16;
  localparam int ICONN_DW = 32;
  localparam int AXI_ID_WIDTH = 8;
  localparam int AXI_DATA_WIDTH = 32;

  logic                          clk;
  logic                          rst_n;

  // ================= ICONN signals =================

  logic [                AW-1:0] raddr;
  logic [          ICONN_DW-1:0] rdata;
  logic                          rcyc;
  logic                          rack;

  logic [                AW-1:0] waddr;
  logic [          ICONN_DW-1:0] wdata;
  logic                          wcyc;
  logic                          wack;

  // ================= AXI signals =================
  logic [      AXI_ID_WIDTH-1:0] aw_id;
  logic [                AW-1:0] aw_addr;
  logic [                   7:0] aw_len;
  logic [                   2:0] aw_size;
  logic [                   1:0] aw_burst;
  logic                          aw_valid;
  logic                          aw_ready;

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
  logic [                   2:0] ar_size;
  logic [                   1:0] ar_burst;
  logic                          ar_valid;
  logic                          ar_ready;

  logic [      AXI_ID_WIDTH-1:0] r_id;
  logic [    AXI_DATA_WIDTH-1:0] r_data;
  logic [                   1:0] r_resp;
  logic                          r_last;
  logic                          r_valid;
  logic                          r_ready;

  // internal signal
  logic [          ICONN_DW-1:0] read_data;

  iconn_axi4_adapter #(
      .AW(AW),
      .ICONN_DW(ICONN_DW),
      .AXI_ID_WIDTH(AXI_ID_WIDTH),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
  ) dut (
      .clk  (clk),
      .rst_n(rst_n),

      .raddr(raddr),
      .rdata(rdata),
      .rcyc (rcyc),
      .rack (rack),

      .waddr(waddr),
      .wdata(wdata),
      .wcyc (wcyc),
      .wack (wack),

      .aw_id(aw_id),
      .aw_addr(aw_addr),
      .aw_len(aw_len),
      .aw_size(aw_size),
      .aw_burst(aw_burst),
      .aw_valid(aw_valid),
      .aw_ready(aw_ready),
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

  axi_ram #(
      .DATA_WIDTH(AXI_DATA_WIDTH),
      .ADDR_WIDTH(AW),
      .ID_WIDTH  (AXI_ID_WIDTH)
  ) ram (
      .clk(clk),
      .rst(!rst_n),

      // ---------------- WRITE ADDRESS ----------------
      .s_axi_awid   (aw_id),
      .s_axi_awaddr (aw_addr),
      .s_axi_awlen  (aw_len),
      .s_axi_awsize (aw_size),
      .s_axi_awburst(aw_burst),
      .s_axi_awlock (1'b0),
      .s_axi_awcache(4'b0),
      .s_axi_awprot (3'b0),
      .s_axi_awvalid(aw_valid),
      .s_axi_awready(aw_ready),

      // ---------------- WRITE DATA ----------------
      .s_axi_wdata (w_data),
      .s_axi_wstrb (w_strb),
      .s_axi_wlast (w_last),
      .s_axi_wvalid(w_valid),
      .s_axi_wready(w_ready),

      // ---------------- WRITE RESPONSE ----------------
      .s_axi_bid   (b_id),
      .s_axi_bresp (b_resp),
      .s_axi_bvalid(b_valid),
      .s_axi_bready(b_ready),

      // ---------------- READ ADDRESS ----------------
      .s_axi_arid   (ar_id),
      .s_axi_araddr (ar_addr),
      .s_axi_arlen  (ar_len),
      .s_axi_arsize (ar_size),
      .s_axi_arburst(ar_burst),
      .s_axi_arlock (1'b0),
      .s_axi_arcache(4'b0),
      .s_axi_arprot (3'b0),
      .s_axi_arvalid(ar_valid),
      .s_axi_arready(ar_ready),

      // ---------------- READ DATA ----------------
      .s_axi_rid   (r_id),
      .s_axi_rdata (r_data),
      .s_axi_rresp (r_resp),
      .s_axi_rlast (r_last),
      .s_axi_rvalid(r_valid),
      .s_axi_rready(r_ready)
  );

  /**********************************
   * TASKS
   **********************************/

  task iconn_write(input [AW-1:0] a, input [ICONN_DW-1:0] d, input [(ICONN_DW/8)-1:0] s);
    begin
      @(posedge clk);
      waddr <= a;
      wdata <= d;
      wcyc  <= 1;

      // Wait for ack
      do @(posedge clk); while (!wack);

      wcyc <= 0;
    end
  endtask

  task iconn_read(input [AW-1:0] a, output [ICONN_DW-1:0] d);
    begin
      @(posedge clk);
      raddr <= a;
      rcyc  <= 1;

      // Wait for ack
      do @(posedge clk); while (!rack);

      d = rdata;

      rcyc <= 0;
    end
  endtask

  /**********************************
   * TEST LOGIC
   **********************************/

  always #5 clk = ~clk;

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_iconn_axi4_adapter);
  end

  // ================= Test sequence =================
  initial begin
    clk   = 0;
    rst_n = 0;

    // Initialize ICONN side
    raddr = 0;
    rcyc  = 0;
    waddr = 0;
    wdata = 0;
    wcyc  = 0;

    // AXI outputs driven by DUT → no need to init
    // AXI inputs from RAM → handled by RAM

    #20;
    rst_n = 1;

    #10;

    // ---------------- WRITE ----------------

    iconn_write(16'h0000, 32'hCAFEBABE, 4'hF);
    iconn_write(16'h0004, 32'hDEADBEEF, 4'hF);

    // ---------------- READ ----------------

    iconn_read(16'h0000, read_data);
    $display("Read 0x0000: %h", read_data);

    if (read_data !== 32'hCAFEBABE) $error("Mismatch at 0x0000");

    iconn_read(16'h0004, read_data);
    $display("Read 0x0004: %h", read_data);

    if (read_data !== 32'hDEADBEEF) $error("Mismatch at 0x0004");

    $display("Test completed successfully!");

    #50 $finish;

  end

endmodule : tb_iconn_axi4_adapter

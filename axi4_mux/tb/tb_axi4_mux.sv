`timescale 1ns/1ps

module tb_axi4_mux;

  // --------------------------------------
  // PARAMETERS
  // --------------------------------------
  localparam int AW = 16;
  localparam int AXI_ID_WIDTH = 4;
  localparam int AXI_DATA_WIDTH = 32;

  localparam int RR_PRIO_NUMBER = 2;
  localparam int FIXED_PRIO_NUMBER = 1;
  localparam int INPUT_NUMBER = RR_PRIO_NUMBER + FIXED_PRIO_NUMBER;

  // --------------------------------------
  // CLOCK / RESET
  // --------------------------------------
  logic clk;
  logic rst_n;

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst_n = 0;
    repeat (5) @(posedge clk);
    rst_n = 1;
  end

  // --------------------------------------
  // DUT SIGNALS
  // --------------------------------------

  // SLAVE SIDE (inputs to mux)
  logic [INPUT_NUMBER-1:0][AXI_ID_WIDTH-1:0] in_aw_id;
  logic [INPUT_NUMBER-1:0][AW-1:0]           in_aw_addr;
  logic [INPUT_NUMBER-1:0][7:0]              in_aw_len;
  logic [INPUT_NUMBER-1:0][2:0]              in_aw_size;
  logic [INPUT_NUMBER-1:0][1:0]              in_aw_burst;
  logic [INPUT_NUMBER-1:0]                   in_aw_valid;
  logic [INPUT_NUMBER-1:0]                   in_aw_ready;

  logic [INPUT_NUMBER-1:0][AXI_DATA_WIDTH-1:0] in_w_data;
  logic [INPUT_NUMBER-1:0][(AXI_DATA_WIDTH/8)-1:0] in_w_strb;
  logic [INPUT_NUMBER-1:0] in_w_last;
  logic [INPUT_NUMBER-1:0] in_w_valid;
  logic [INPUT_NUMBER-1:0] in_w_ready;

  logic [INPUT_NUMBER-1:0][AXI_ID_WIDTH-1:0] in_b_id;
  logic [INPUT_NUMBER-1:0][1:0] in_b_resp;
  logic [INPUT_NUMBER-1:0] in_b_valid;
  logic [INPUT_NUMBER-1:0] in_b_ready;

  logic [INPUT_NUMBER-1:0][AXI_ID_WIDTH-1:0] in_ar_id;
  logic [INPUT_NUMBER-1:0][AW-1:0] in_ar_addr;
  logic [INPUT_NUMBER-1:0][7:0] in_ar_len;
  logic [INPUT_NUMBER-1:0][2:0] in_ar_size;
  logic [INPUT_NUMBER-1:0][1:0] in_ar_burst;
  logic [INPUT_NUMBER-1:0] in_ar_valid;
  logic [INPUT_NUMBER-1:0] in_ar_ready;

  logic [INPUT_NUMBER-1:0][AXI_ID_WIDTH-1:0] in_r_id;
  logic [INPUT_NUMBER-1:0][AXI_DATA_WIDTH-1:0] in_r_data;
  logic [INPUT_NUMBER-1:0][1:0] in_r_resp;
  logic [INPUT_NUMBER-1:0] in_r_last;
  logic [INPUT_NUMBER-1:0] in_r_valid;
  logic [INPUT_NUMBER-1:0] in_r_ready;

  // MASTER SIDE (to RAM)
  logic [AXI_ID_WIDTH-1:0] out_aw_id;
  logic [AW-1:0]           out_aw_addr;
  logic [7:0]              out_aw_len;
  logic [2:0]              out_aw_size;
  logic [1:0]              out_aw_burst;
  logic                    out_aw_valid;
  logic                    out_aw_ready;

  logic [AXI_DATA_WIDTH-1:0] out_w_data;
  logic [(AXI_DATA_WIDTH/8)-1:0] out_w_strb;
  logic out_w_last;
  logic out_w_valid;
  logic out_w_ready;

  logic [AXI_ID_WIDTH-1:0] out_b_id;
  logic [1:0] out_b_resp;
  logic out_b_valid;
  logic out_b_ready;

  logic [AXI_ID_WIDTH-1:0] out_ar_id;
  logic [AW-1:0] out_ar_addr;
  logic [7:0] out_ar_len;
  logic [2:0] out_ar_size;
  logic [1:0] out_ar_burst;
  logic out_ar_valid;
  logic out_ar_ready;

  logic [AXI_ID_WIDTH-1:0] out_r_id;
  logic [AXI_DATA_WIDTH-1:0] out_r_data;
  logic [1:0] out_r_resp;
  logic out_r_last;
  logic out_r_valid;
  logic out_r_ready;

  // --------------------------------------
  // DUT
  // --------------------------------------
  axi4_mux #(
    .AW(AW),
    .AXI_ID_WIDTH(AXI_ID_WIDTH),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .RR_PRIO_NUMBER(RR_PRIO_NUMBER),
    .FIXED_PRIO_NUMBER(FIXED_PRIO_NUMBER)
  ) dut (.*);

  // --------------------------------------
  // AXI RAM (downstream)
  // --------------------------------------
  axi_ram #(
    .DATA_WIDTH(AXI_DATA_WIDTH),
    .ADDR_WIDTH(AW),
    .ID_WIDTH(AXI_ID_WIDTH)
  ) ram (
    .clk(clk),
    .rst(~rst_n),

    .s_axi_awid(out_aw_id),
    .s_axi_awaddr(out_aw_addr),
    .s_axi_awlen(out_aw_len),
    .s_axi_awsize(out_aw_size),
    .s_axi_awburst(out_aw_burst),
    .s_axi_awlock(1'b0),
    .s_axi_awcache(4'b0),
    .s_axi_awprot(3'b0),
    .s_axi_awvalid(out_aw_valid),
    .s_axi_awready(out_aw_ready),

    .s_axi_wdata(out_w_data),
    .s_axi_wstrb(out_w_strb),
    .s_axi_wlast(out_w_last),
    .s_axi_wvalid(out_w_valid),
    .s_axi_wready(out_w_ready),

    .s_axi_bid(out_b_id),
    .s_axi_bresp(out_b_resp),
    .s_axi_bvalid(out_b_valid),
    .s_axi_bready(out_b_ready),

    .s_axi_arid(out_ar_id),
    .s_axi_araddr(out_ar_addr),
    .s_axi_arlen(out_ar_len),
    .s_axi_arsize(out_ar_size),
    .s_axi_arburst(out_ar_burst),
    .s_axi_arlock(1'b0),
    .s_axi_arcache(4'b0),
    .s_axi_arprot(3'b0),
    .s_axi_arvalid(out_ar_valid),
    .s_axi_arready(out_ar_ready),

    .s_axi_rid(out_r_id),
    .s_axi_rdata(out_r_data),
    .s_axi_rresp(out_r_resp),
    .s_axi_rlast(out_r_last),
    .s_axi_rvalid(out_r_valid),
    .s_axi_rready(out_r_ready)
  );

  // --------------------------------------
  // DEFAULTS
  // --------------------------------------
  initial begin
    in_aw_valid = '0;
    in_w_valid  = '0;
    in_b_ready  = '1;

    in_ar_valid = '0;
    in_r_ready  = '1;
  end

  // --------------------------------------
  // SIMPLE WRITE TASK
  // --------------------------------------
  task automatic axi_write(input int master, input [AW-1:0] addr, input [31:0] data);
    begin
      // AW
      in_aw_id[master]    <= master;
      in_aw_addr[master]  <= addr;
      in_aw_len[master]   <= 0;
      in_aw_size[master]  <= 3'b010;
      in_aw_burst[master] <= 2'b01;
      in_aw_valid[master] <= 1;

      wait (in_aw_ready[master]);
      @(posedge clk);
      in_aw_valid[master] <= 0;

      // W
      in_w_data[master]  <= data;
      in_w_strb[master]  <= '1;
      in_w_last[master]  <= 1;
      in_w_valid[master] <= 1;

      wait (in_w_ready[master]);
      @(posedge clk);
      in_w_valid[master] <= 0;

      // B
      wait (in_b_valid[master]);
      @(posedge clk);
    end
  endtask

  // --------------------------------------
  // SIMPLE READ TASK
  // --------------------------------------
  task automatic axi_read(input int master, input [AW-1:0] addr);
    begin
      in_ar_id[master]    <= master;
      in_ar_addr[master]  <= addr;
      in_ar_len[master]   <= 0;
      in_ar_size[master]  <= 3'b010;
      in_ar_burst[master] <= 2'b01;
      in_ar_valid[master] <= 1;

      wait (in_ar_ready[master]);
      @(posedge clk);
      in_ar_valid[master] <= 0;

      wait (in_r_valid[master]);
      $display("READ M%0d ADDR=%h DATA=%h", master, addr, in_r_data[master]);
      @(posedge clk);
    end
  endtask

  // --------------------------------------
  // TEST
  // --------------------------------------
  initial begin
    wait(rst_n);

    // Single master test
    axi_write(0, 16'h0010, 32'hDEADBEEF);
    axi_read (0, 16'h0010);

    // Multi-master contention
    fork
      axi_write(0, 16'h0020, 32'hAAAA0001);
      axi_write(1, 16'h0024, 32'hBBBB0002);
      axi_write(2, 16'h0028, 32'hCCCC0003);
    join

    fork
      axi_read(0, 16'h0020);
      axi_read(1, 16'h0024);
      axi_read(2, 16'h0028);
    join

    #100;
    $finish;
  end

endmodule
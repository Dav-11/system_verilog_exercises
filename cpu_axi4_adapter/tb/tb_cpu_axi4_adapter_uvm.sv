`timescale 1ns / 1ps

module tb_cpu_axi4_adapter;

  logic clk;
  logic rst_n;

  always #5 clk = ~clk;

  cpu_if cpu_if (clk);
  axi_if axi_if (clk);

  cpu_axi4_adapter dut (
      .clk  (clk),
      .rst_n(rst_n),

      .req(cpu_if.req),
      .we(cpu_if.we),
      .addr(cpu_if.addr),
      .wdata(cpu_if.wdata),
      .sel(cpu_if.sel),
      .rdata(cpu_if.rdata),
      .ack(cpu_if.ack),

      .aw_id(axi_if.aw_id),
      .aw_addr(axi_if.aw_addr),
      .aw_len(axi_if.aw_len),
      .aw_size(axi_if.aw_size),
      .aw_burst(axi_if.aw_burst),
      .aw_valid(axi_if.aw_valid),
      .aw_ready(axi_if.aw_ready),

      .w_data (axi_if.w_data),
      .w_strb (axi_if.w_strb),
      .w_last (axi_if.w_last),
      .w_valid(axi_if.w_valid),
      .w_ready(axi_if.w_ready),

      .b_id(axi_if.b_id),
      .b_resp(axi_if.b_resp),
      .b_valid(axi_if.b_valid),
      .b_ready(axi_if.b_ready),

      .ar_id(axi_if.ar_id),
      .ar_addr(axi_if.ar_addr),
      .ar_len(axi_if.ar_len),
      .ar_size(axi_if.ar_size),
      .ar_burst(axi_if.ar_burst),
      .ar_valid(axi_if.ar_valid),
      .ar_ready(axi_if.ar_ready),

      .r_id(axi_if.r_id),
      .r_data(axi_if.r_data),
      .r_resp(axi_if.r_resp),
      .r_last(axi_if.r_last),
      .r_valid(axi_if.r_valid),
      .r_ready(axi_if.r_ready)
  );

endmodule

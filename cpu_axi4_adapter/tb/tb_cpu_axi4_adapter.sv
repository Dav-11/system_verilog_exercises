`timescale 1ns / 1ps

module tb_cpu_axi4_adapter;

  // Parameters (match your DUT)
  localparam AW = 32;
  localparam CPU_DW = 64;
  localparam AXI_ID_WIDTH = 8;
  localparam AXI_DATA_WIDTH = 256;

  // Clock & reset
  logic clk;
  logic rst_n;

  always #5 clk = ~clk;

  // ================= CPU signals =================
  logic req;
  logic we;
  logic [AW-1:0] addr;
  logic [CPU_DW-1:0] wdata;
  logic [(CPU_DW/8)-1:0] sel;

  logic [CPU_DW-1:0] rdata;
  logic ack;

  // ================= AXI signals =================
  logic [AXI_ID_WIDTH-1:0] aw_id;
  logic [AW-1:0] aw_addr;
  logic [7:0] aw_len;
  logic [2:0] aw_size;
  logic [1:0] aw_burst;
  logic aw_valid;
  logic aw_ready;

  logic [AXI_DATA_WIDTH-1:0] w_data;
  logic [(AXI_DATA_WIDTH/8)-1:0] w_strb;
  logic w_last;
  logic w_valid;
  logic w_ready;

  logic [AXI_ID_WIDTH-1:0] b_id;
  logic [1:0] b_resp;
  logic b_valid;
  logic b_ready;

  logic [AXI_ID_WIDTH-1:0] ar_id;
  logic [AW-1:0] ar_addr;
  logic [7:0] ar_len;
  logic [2:0] ar_size;
  logic [1:0] ar_burst;
  logic ar_valid;
  logic ar_ready;

  logic [AXI_ID_WIDTH-1:0] r_id;
  logic [AXI_DATA_WIDTH-1:0] r_data;
  logic [1:0] r_resp;
  logic r_last;
  logic r_valid;
  logic r_ready;

  // ================= DUT =================
  cpu_axi4_adapter #(
      .AW(AW),
      .CPU_DW(CPU_DW),
      .AXI_ID_WIDTH(AXI_ID_WIDTH),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .req(req),
      .we(we),
      .addr(addr),
      .wdata(wdata),
      .sel(sel),
      .rdata(rdata),
      .ack(ack),
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

  // ================= Simple AXI memory model =================
  localparam MEM_SIZE = 32;  // reduce memory to 32 rows
  logic [AXI_DATA_WIDTH-1:0] mem[0:MEM_SIZE-1];
  logic [CPU_DW-1:0] read_data;

  // AXI handshake
  assign aw_ready = 1;
  assign w_ready  = 1;
  assign ar_ready = 1;
  assign b_valid  = aw_valid && w_valid;
  assign b_resp   = 2'b00;
  assign r_valid  = ar_valid;
  assign r_last   = 1;
  assign r_resp   = 2'b00;

  always_ff @(posedge clk) begin
    if (w_valid && w_ready) begin
      mem[(aw_addr>>$clog2(AXI_DATA_WIDTH/8)) % MEM_SIZE] <= w_data; // wrap address
    end
    if (r_valid && ar_valid) begin
      r_data <= mem[(ar_addr>>$clog2(AXI_DATA_WIDTH/8)) % MEM_SIZE]; // wrap address
    end
  end

  // ================= CPU stimulus =================
  task cpu_write(input [AW-1:0] a, input [CPU_DW-1:0] d, input [(CPU_DW/8)-1:0] s);
    begin
      @(posedge clk);
      addr <= a;
      wdata <= d;
      sel <= s;
      we <= 1;
      req <= 1;
      @(posedge clk);
      req <= 0;
      wait (ack);
    end
  endtask

  task cpu_read(input [AW-1:0] a, output [CPU_DW-1:0] d);
    begin
      @(posedge clk);
      addr <= a;
      we   <= 0;
      req  <= 1;
      @(posedge clk);
      req <= 0;
      wait (ack);
      d = rdata;
    end
  endtask

  // ================= Test sequence =================
  initial begin

    clk <= 0;
    rst_n = 0;

    #20;
    rst_n = 1;

    #10

    // Write to addresses inside 32-row memory (32 bytes per row)
    cpu_write(32'h0000, 64'hDEADBEEFCAFEBABE, 8'hFF);
    cpu_write(32'h0020, 64'h0123456789ABCDEF, 8'hFF);  // next row (32 bytes ahead)

    // Read back
    cpu_read(32'h0000, read_data);
    $display("Read 0x0000: %h", read_data);

    cpu_read(32'h0020, read_data);
    $display("Read 0x0020: %h", read_data);

    // Check values
    if (read_data !== 64'h0123456789ABCDEF) $error("Data mismatch!");

    $display("Test completed successfully!");
    #50 $finish;
  end

endmodule

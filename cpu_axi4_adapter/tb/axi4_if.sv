interface axi4_if #(
    parameter AW = 32,
    DW = 256,
    IDW = 8
) (
    input logic clk
);

  logic [IDW-1:0] aw_id;
  logic [AW-1:0] aw_addr;
  logic [7:0] aw_len;
  logic [2:0] aw_size;
  logic [1:0] aw_burst;
  logic aw_valid;
  logic aw_ready;

  logic [DW-1:0] w_data;
  logic [DW/8-1:0] w_strb;
  logic w_last;
  logic w_valid;
  logic w_ready;

  logic [IDW-1:0] b_id;
  logic [1:0] b_resp;
  logic b_valid;
  logic b_ready;

  logic [IDW-1:0] ar_id;
  logic [AW-1:0] ar_addr;
  logic [7:0] ar_len;
  logic [2:0] ar_size;
  logic [1:0] ar_burst;
  logic ar_valid;
  logic ar_ready;

  logic [IDW-1:0] r_id;
  logic [DW-1:0] r_data;
  logic [1:0] r_resp;
  logic r_last;
  logic r_valid;
  logic r_ready;

endinterface

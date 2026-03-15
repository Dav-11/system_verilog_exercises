interface cpu_if #(
    parameter AW = 32,
    DW = 64
) (
    input logic clk
);

  logic req;
  logic we;
  logic [AW-1:0] addr;
  logic [DW-1:0] wdata;
  logic [DW/8-1:0] sel;

  logic [DW-1:0] rdata;
  logic ack;

endinterface

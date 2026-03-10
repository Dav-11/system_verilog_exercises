module cpu_axi4_adapter #(
    parameter int AW = 32,
    parameter int DW = 64,
    parameter int AXI_ID_WIDTH = 8,
    parameter int AXI_DATA_WIDTH = 256
) (
    input logic clk,
    input logic rst_n,

    // ================= CPU SIDE =================
    input logic              req,
    input logic              we,
    input logic [    AW-1:0] addr,
    input logic [    DW-1:0] wdata,
    input logic [(DW/8)-1:0] sel,

    output logic [DW-1:0] rdata,
    output logic          ack,

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
    //output logic [             2:0] ar_size,
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

  typedef enum logic [2:0] {
    IDLE,
    WRITE_ADDR,
    WRITE_DATA,
    WRITE_RESP,
    READ_ADDR,
    READ_DATA
  } state_t;

  state_t state_r, state_n;

  always_ff @(posedge clk) begin
    if (!rst_n) begin

      state_r <= IDLE;
    end else begin

      state_r <= state_n;
    end
  end


endmodule : cpu_axi4_adapter

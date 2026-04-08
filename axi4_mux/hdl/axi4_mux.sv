module axi4_mux #(
    parameter int AW = 32,
    parameter int AXI_ID_WIDTH = 8,
    parameter int AXI_DATA_WIDTH = 256,
    parameter int RR_PRIO_NUMBER = 4,
    parameter int FIXED_PRIO_NUMBER = 1,
    localparam int INPUT_NUMBER = RR_PRIO_NUMBER + FIXED_PRIO_NUMBER
) (

    // control signals
    input logic clk,
    input logic rst_n,

    // MUX IN
    // ================= AXI SLAVE SIDE =================

    // Write address
    input  logic [INPUT_NUMBER-1:0][AXI_ID_WIDTH-1:0] in_aw_id,
    input  logic [INPUT_NUMBER-1:0][          AW-1:0] in_aw_addr,
    input  logic [INPUT_NUMBER-1:0][             7:0] in_aw_len,
    input  logic [INPUT_NUMBER-1:0][             2:0] in_aw_size,
    input  logic [INPUT_NUMBER-1:0][             1:0] in_aw_burst,
    input  logic [INPUT_NUMBER-1:0]                   in_aw_valid,
    output logic [INPUT_NUMBER-1:0]                   in_aw_ready,

    // Write data
    input  logic [INPUT_NUMBER-1:0][    AXI_DATA_WIDTH-1:0] in_w_data,
    input  logic [INPUT_NUMBER-1:0][(AXI_DATA_WIDTH/8)-1:0] in_w_strb,
    input  logic [INPUT_NUMBER-1:0]                         in_w_last,
    input  logic [INPUT_NUMBER-1:0]                         in_w_valid,
    output logic [INPUT_NUMBER-1:0]                         in_w_ready,

    // Write response
    output logic [INPUT_NUMBER-1:0][AXI_ID_WIDTH-1:0] in_b_id,
    output logic [INPUT_NUMBER-1:0][             1:0] in_b_resp,
    output logic [INPUT_NUMBER-1:0]                   in_b_valid,
    input  logic [INPUT_NUMBER-1:0]                   in_b_ready,

    // Read address
    input  logic [INPUT_NUMBER-1:0][AXI_ID_WIDTH-1:0] in_ar_id,
    input  logic [INPUT_NUMBER-1:0][          AW-1:0] in_ar_addr,
    input  logic [INPUT_NUMBER-1:0][             7:0] in_ar_len,
    input  logic [INPUT_NUMBER-1:0][             2:0] in_ar_size,
    input  logic [INPUT_NUMBER-1:0][             1:0] in_ar_burst,
    input  logic [INPUT_NUMBER-1:0]                   in_ar_valid,
    output logic [INPUT_NUMBER-1:0]                   in_ar_ready,

    // Read data
    output logic [INPUT_NUMBER-1:0][  AXI_ID_WIDTH-1:0] in_r_id,
    output logic [INPUT_NUMBER-1:0][AXI_DATA_WIDTH-1:0] in_r_data,
    output logic [INPUT_NUMBER-1:0][               1:0] in_r_resp,
    output logic [INPUT_NUMBER-1:0]                     in_r_last,
    output logic [INPUT_NUMBER-1:0]                     in_r_valid,
    input  logic [INPUT_NUMBER-1:0]                     in_r_ready,


    // MUX OUT
    // ================= AXI MASTER SIDE =================

    // Write address
    output logic [AXI_ID_WIDTH-1:0] out_aw_id,
    output logic [          AW-1:0] out_aw_addr,
    output logic [             7:0] out_aw_len,
    output logic [             2:0] out_aw_size,
    output logic [             1:0] out_aw_burst,
    output logic                    out_aw_valid,
    input  logic                    out_aw_ready,

    // Write data
    output logic [    AXI_DATA_WIDTH-1:0] out_w_data,
    output logic [(AXI_DATA_WIDTH/8)-1:0] out_w_strb,
    output logic                          out_w_last,
    output logic                          out_w_valid,
    input  logic                          out_w_ready,

    // Write response
    input  logic [AXI_ID_WIDTH-1:0] out_b_id,
    input  logic [             1:0] out_b_resp,
    input  logic                    out_b_valid,
    output logic                    out_b_ready,

    // Read address
    output logic [AXI_ID_WIDTH-1:0] out_ar_id,
    output logic [          AW-1:0] out_ar_addr,
    output logic [             7:0] out_ar_len,
    output logic [             2:0] out_ar_size,
    output logic [             1:0] out_ar_burst,
    output logic                    out_ar_valid,
    input  logic                    out_ar_ready,

    // Read data
    input  logic [  AXI_ID_WIDTH-1:0] out_r_id,
    input  logic [AXI_DATA_WIDTH-1:0] out_r_data,
    input  logic [               1:0] out_r_resp,
    input  logic                      out_r_last,
    input  logic                      out_r_valid,
    output logic                      out_r_ready
);

  logic [INPUT_NUMBER-1:0] sel_r, sel_w;
  logic busy_r, busy_w;

endmodule : axi4_mux

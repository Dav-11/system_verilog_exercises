module axi4_mux_w #(
    parameter int AW = 32,
    parameter int AXI_ID_WIDTH = 8,
    parameter int AXI_DATA_WIDTH = 256,
    parameter int RR_PRIO_NUMBER = 4,
    parameter int FIXED_PRIO_NUMBER = 1,
    localparam int INPUT_NUMBER = RR_PRIO_NUMBER + FIXED_PRIO_NUMBER
) (

    // control signals
    input logic [INPUT_NUMBER-1:0] sel,

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
    output logic                    out_b_ready

);

  always_comb begin

    // ======================================
    // DEFAULTS
    // ======================================

    in_aw_ready  = '0;

    in_w_ready   = '0;

    in_b_id      = '0;
    in_b_resp    = '0;
    in_b_valid   = '0;

    out_aw_id    = '0;
    out_aw_addr  = '0;
    out_aw_len   = '0;
    out_aw_size  = '0;
    out_aw_burst = '0;
    out_aw_valid = '0;

    out_w_data   = '0;
    out_w_strb   = '0;
    out_w_last   = '0;
    out_w_valid  = '0;

    out_b_ready  = '0;

    for (int i = 0; i < INPUT_NUMBER; i++) begin
      if (sel[i]) begin

        in_aw_ready[i] = out_aw_ready;

        in_w_ready[i]  = out_w_ready;

        in_b_id[i]     = out_b_id;
        in_b_resp[i]   = out_b_resp;
        in_b_valid[i]  = out_b_valid;

        out_aw_id      = in_aw_id[i];
        out_aw_addr    = in_aw_addr[i];
        out_aw_len     = in_aw_len[i];
        out_aw_size    = in_aw_size[i];
        out_aw_burst   = in_aw_burst[i];
        out_aw_valid   = in_aw_valid[i];

        out_w_data     = in_w_data[i];
        out_w_strb     = in_w_strb[i];
        out_w_last     = in_w_last[i];
        out_w_valid    = in_w_valid[i];

        out_b_ready    = in_b_ready[i];
      end
    end
  end

endmodule : axi4_mux_w

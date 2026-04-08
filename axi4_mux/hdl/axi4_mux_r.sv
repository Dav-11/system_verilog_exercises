module axi4_mux_r #(
    parameter int AW = 32,
    parameter int AXI_ID_WIDTH = 8,
    parameter int AXI_DATA_WIDTH = 256,
    parameter int RR_PRIO_NUMBER = 4,
    parameter int FIXED_PRIO_NUMBER = 1,
    localparam int INPUT_NUMBER = RR_PRIO_NUMBER + FIXED_PRIO_NUMBER
) (

    // control signals
    input logic [INPUT_NUMBER-1:0] sel,

    // MUX IN
    // ================= AXI SLAVE SIDE =================

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

  always_comb begin

    // ======================================
    // DEFAULTS
    // ======================================

    in_ar_ready  = '0;

    in_r_id      = '0;
    in_r_data    = '0;
    in_r_resp    = '0;
    in_r_last    = '0;
    in_r_valid   = '0;

    out_ar_id    = '0;
    out_ar_addr  = '0;
    out_ar_len   = '0;
    out_ar_size  = '0;
    out_ar_burst = '0;
    out_ar_valid = '0;

    out_r_ready  = '0;

    // ======================================
    // MUX LOGIC
    // ======================================

    for (int i = 0; i < INPUT_NUMBER; i++) begin
      if (sel[i]) begin

        in_ar_ready[i] = out_ar_ready;

        in_r_id[i]    = out_r_id;
        in_r_data[i]  = out_r_data;
        in_r_resp[i]  = out_r_resp;
        in_r_last[i]  = out_r_last;
        in_r_valid[i] = out_r_valid;

        out_ar_id    = in_ar_id[i];
        out_ar_addr  = in_ar_addr[i];
        out_ar_len   = in_ar_len[i];
        out_ar_size  = in_ar_size[i];
        out_ar_burst = in_ar_burst[i];
        out_ar_valid = in_ar_valid[i];

        out_r_ready = in_r_ready[i];

      end
    end
  end

endmodule : axi4_mux_r

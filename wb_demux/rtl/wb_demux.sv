`define MAX2(v1, v2) ((v1) > (v2) ? (v1) : (v2))

module wb_demux #(
    parameter logic [CPU_ID_WIDTH-1:0] CPU_ID = 0,
    parameter logic                    N      = 4   // number of outputs
) (
    // input logic clk,
    // input logic resetn,
    input logic [`MAX2($clog2(N), 1)-1:0] select_out,

    //=============== INPUT ===============
    input logic                 in_req_m2dbiu,
    input logic [  DBUS_AW-1:0] in_adr_m2dbiu,
    input logic [  DBUS_DW-1:0] in_dat_m2dbiu,
    input logic                 in_we_m2dbiu,
    input logic [DBUS_ISEL-1:0] in_sel_m2dbiu,
    input logic [  DBUS_DW-1:0] in_dat_dbiu2m,
    input logic                 in_ack_dbiu2m,

    //=============== OUT ===============
    output logic [N-1:0]                out_req_m2dbiu,
    output logic [N-1:0][  DBUS_AW-1:0] out_adr_m2dbiu,
    output logic [N-1:0][  DBUS_DW-1:0] out_dat_m2dbiu,
    output logic [N-1:0]                out_we_m2dbiu,
    output logic [N-1:0][DBUS_ISEL-1:0] out_sel_m2dbiu,
    output logic [N-1:0][  DBUS_DW-1:0] out_dat_dbiu2m,
    output logic [N-1:0]                out_ack_dbiu2m
);

  always_comb begin
    // Default outputs
    out_req_m2dbiu             = '0;
    out_adr_m2dbiu             = '0;
    out_dat_m2dbiu             = '0;
    out_we_m2dbiu              = '0;
    out_sel_m2dbiu             = '0;
    out_dat_dbiu2m             = '0;
    out_ack_dbiu2m             = '0;

    // Muxing logic
    out_req_m2dbiu[select_out] = in_req_m2dbiu;
    out_adr_m2dbiu[select_out] = in_adr_m2dbiu;
    out_dat_m2dbiu[select_out] = in_dat_m2dbiu;
    out_we_m2dbiu[select_out]  = in_we_m2dbiu;
    out_sel_m2dbiu[select_out] = in_sel_m2dbiu;
    out_dat_dbiu2m[select_out] = in_dat_dbiu2m;
    out_ack_dbiu2m[select_out] = in_ack_dbiu2m;
  end


endmodule : wb_mux

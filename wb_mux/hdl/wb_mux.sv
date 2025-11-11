`define MAX2(v1, v2) ((v1) > (v2) ? (v1) : (v2))

module wb_mux #(
    parameter logic N = 4  // number of inputs
) (
    // input logic clk,
    // input logic resetn,
    input logic [`MAX2($clog2(N), 1)-1:0] select_out,

    //=============== INPUT ===============

    input logic [N-1:0][NUM_MASTER-1:0]         in_ack,
    input logic [N-1:0][(BYTES_PER_LINE*8)-1:0] in_wdata,
    input logic [N-1:0][MAIN_MEM_LINE_AW-1:0]   in_waddr,
    input logic [N-1:0][MAIN_MEM_LINE_AW-1:0]   in_raddr,
    input logic [N-1:0]                         in_rcyc,
    input logic [N-1:0]                         in_wcyc,

    //=============== OUT ===============
    output logic [N-1:0]                out_req_m2dbiu,
    output logic [N-1:0][  DBUS_AW-1:0] out_adr_m2dbiu,
    output logic [N-1:0][  DBUS_DW-1:0] out_dat_m2dbiu,
    output logic [N-1:0]                out_we_m2dbiu,
    output logic [N-1:0][DBUS_ISEL-1:0] out_sel_m2dbiu,
    output logic [N-1:0][  DBUS_DW-1:0] out_dat_dbiu2m,
    output logic [N-1:0]                out_ack_dbiu2m,


    .rcyc (rcyc),
      .wcyc (wcyc),
      .waddr(waddr),
      .raddr(raddr),
      .wdata(wdata),

      .rdata(rdata)

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

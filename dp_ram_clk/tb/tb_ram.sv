`timescale 1ns / 10ps

module tb_ram ();

    parameter HALF_CLK = 1;

    logic clk = 0;

    dp_ram_clk #(.DPRAM_AW(TAGMEM_AW), .DPRAM_DW(TAGMEM_DW)) tag_mem0 (

        .clk        (clk),

        // Always read on port A
        .cyc_a_i    (tag_rcyc),
        .we_a_i     (1'b0),
        .adr_a_i    (tag_rindex),
        .dat_a_i    ('0),

        // Always write on port B
        .cyc_b_i    (tag_wcyc),
        .we_b_i     (1'b1),
        .adr_b_i    (tag_windex),
        .dat_b_i    (tag_din),

        .dat_a_o    (tag_dout),
        .dat_b_o    ()
    );

    // Clock generation
    always #HALF_CLK clk = ~clk;

    initial begin

    end;

endmodule: tb_ram
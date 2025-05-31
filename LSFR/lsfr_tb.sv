`timescale 1ns/10ps
module tb_lsfr ();
    parameter HALF_CLK = 5;

    logic clk;
    logic d_i;
    logic d_o;
    logic rss;

    lsfr lsfr_i (
        .d_i(d_i),
        .d_o(d_o),
        .rss(rss),
        .clk(clk)
    )

    always #HALF_CLK clk = ~ clk;

    initial
    begin
        clk <= '0;
        rss <= '0;
        d_o <= '0;
        d_i <= '0;


    end

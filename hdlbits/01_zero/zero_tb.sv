`timescale 1ns/10ps

module tb_zero();
    parameter HALF_CLK = 5;

    logic clk;
    logic zero;

    top_module top_module_i (
        .zero(zero)
    )

    always #HALF_CLK clk = ~ clk;

    initial
    begin
        clk <= '0;
    end

endmodule: tb_zero

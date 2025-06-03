`timescale 1ns / 10ps

// `include "adder_if.sv"
// `include "adder.sv"

module tb_adder ();
    parameter HALF_CLK = 1;

    adder_if #(4) bus ();
    logic clk = 0;

    adder dut (.bus(bus));

    always #HALF_CLK clk = ~clk;

    initial begin

        // C++ main handles VCD dumping; these will likely be ignored
        // or cause issues if you're using the C++ tracing API.
        // If you are using the C++ sim_main.cpp, you can comment these out:
        // $dumpfile("adder.vcd");
        // $dumpvars(0, dut);

        $monitor("Time: %0d, rst: %b, a: %b, b: %b, sum: %b, carry: %b", $time, bus.rst, bus.a,
                 bus.b, bus.sum, bus.carry);

        clk <= 0;
        bus.rst <= 1;
        bus.a <= '0;
        bus.b <= '0;

        $strobe("sum=%b, cout=%b", bus.sum, bus.carry);

        #2 bus.rst <= 0;
        bus.a <= 4'b0010;
        bus.b <= 4'b0011;

        $strobe("sum=%b, cout=%b", bus.sum, bus.carry);

        // reset
        // #2 bus.rst <= 1;
        
        #2 bus.rst <= 0;
        bus.a <= 4'b1111;
        bus.b <= 4'b0001;
        
        #4 // delay
        $finish;
    end

endmodule

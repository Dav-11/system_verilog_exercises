`timescale 1ns / 10ps

`include "adder_if.sv"
`include "adder.sv"

module tb_adder;
    adder_if #(4) bus ();

    adder dut (.bus(bus));

    initial begin

        $dumpfile("adder.vcd");
        $dumpvars(0, dut);

        $display("Starting test...");
        bus.a = 4'b0000;
        bus.b = 4'b0000;
        #1 $display("sum=%b, cout=%b", bus.sum, bus.carry);

        bus.a = 4'b0010;
        bus.b = 4'b0001;
        #1 $display("sum=%b, cout=%b", bus.sum, bus.carry);

        // Add more test vectors here

        $finish;
    end

endmodule

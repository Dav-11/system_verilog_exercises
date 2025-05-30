`include "adder_if.sv"

module adder (
    adder_if.adder bus
);

    always_comb begin
        {bus.carry, bus.sum} = bus.a + bus.b;
    end




endmodule

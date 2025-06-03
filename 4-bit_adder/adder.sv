// `include "adder_if.sv"

module adder (
    adder_if.adder bus
);

    always_comb begin
        if (bus.rst == 1) {bus.carry, bus.sum} = '0;
        else {bus.carry, bus.sum} = bus.a + bus.b;
    end

endmodule : adder

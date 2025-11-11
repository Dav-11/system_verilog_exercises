package adder_pkg;
    parameter WIDTH = 4;
endpackage : adder_pkg



interface adder_if;
    import adder_pkg::*;
    logic rst;
    logic [WIDTH -1:0] a;
    logic [WIDTH -1:0] b;
    logic [WIDTH -1:0] sum;
    logic carry;

    // modport for the adder
    modport adder(input a, b, rst, output sum, carry);
    modport tb(input sum, carry, output a, b, rst);

endinterface : adder_if

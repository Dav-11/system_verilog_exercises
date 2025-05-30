`timescale 1ns / 10ps

module tb_adder4;
    logic [3:0] a, b;
    logic       cin;
    logic [3:0] sum;
    logic       cout;

    adder uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        $display("Starting test...");
        a   = 4'b0000;
        b   = 4'b0000;
        cin = 0;
        #1 $display("sum=%b, cout=%b", sum, cout);

        // Add more test vectors here

        $finish;
    end

endmodule

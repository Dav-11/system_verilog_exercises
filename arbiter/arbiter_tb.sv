`timescale 1ns/10ps
module arbiter_tb;

  parameter num_master = 4;

  // Input and Output signals
  logic clk;
  logic rst;
  logic [num_master-1:0] req;
  logic [num_master-1:0] pri;
  logic [num_master-1:0] grant;

  // DUT instantiation
  arbiter #( .num_master(num_master) ) dut (.clk(clk), .req(req), .pri(pri), .grant(grant), .rst(rst));

  // Clock generation
  always #5 clk = ~ clk;

  // Random stimulus generation
  initial begin

    $monitor("Time: %0d, grant: %b", $time, grant);
    
    clk <= 0;
    rst <= 1;
    req <= '0;
    pri <= '0;
    
    #10
    rst <= 0;
    req <= 'b0110;
    pri <= 'b0100;

    #10
    rst <= 0;
    req <= 'b0110;
    pri <= 'b0010;

    #6
    rst <= 1;

    # 10
    $finish;
  end

endmodule

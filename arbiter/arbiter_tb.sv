`timescale 1ns/10ps
module arbiter_tb;

  // Input and Output signals
  logic clk;
  logic [num_master-1:0] req;
  logic [num_master-1:0] pri;
  logic [num_master-1:0] grant;

  // DUT instantiation
  arbiter #( .num_master(4) ) dut (clk, req, pri, grant);

  // Clock generation
  always #5 clk = ~ clk;

  // Random stimulus generation
  initial begin
    
    req <= '0;
    pri <= '0;
    
    #10
    req <= 'b0110;
    pri <= 'b0100;
    $monitor("Time: %0d, grant: %b", $time, grant);

  end

endmodule

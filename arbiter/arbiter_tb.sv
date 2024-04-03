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

    $dumpfile("arbiter.vcd");
    $dumpvars(0,dut);

    $monitor("Time: %0d, grant: %b", $time, grant);
    
    clk <= 0;
    rst <= 1;
    req <= '0;
    pri <= '0;
    
    #10
    rst <= 0;
    req <= 'b0110;
    pri <= 'b0100;
    $strobe("skip: %b", dut.grant);

    #10
    req <= 'b0110;
    pri <= 'b0010;
    $strobe("skip: %b", dut.grant);

    #10
    req <= 'b0110;
    pri <= 'b0001;
    $strobe("skip_s: %b", dut.grant);
    $strobe("skip_s: %b", dut.grant);
    $display("req_d: %b", dut.req);
    $display("req_ext_d: %b", dut.req_ext);
    $display("pri_ext_d: %b", dut.pri_ext);
    $display("skip_d: %b", dut.grant);
    $display("found_d: %b", dut.found);
    $display("grant_d: %b", dut.grant);

    #10
    $display("req_ext_d: %b", dut.req_ext);
    $display("pri_ext_d: %b", dut.pri_ext);
    rst <= 1;

    # 10
    $finish;
  end

endmodule

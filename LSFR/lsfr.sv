module lsfr (d_i, d_o, clk, rss);
  input logic clk;
  input logic rss;
  input logic d_i;
  output logic d_o;

  always_ff @( posedge clk )
  begin:
    
  end
module lsfr (d_i, d_o, clk, rss);

  input   logic         clk;
  input   logic         rss;
  input   logic         d_i;
  output  logic         d_o;

  logic [15:0]  r;
  logic [15:0]  r_n;
  logic [14:0]  r_s;

  always_comb
  begin:
    r_s = r >> 1; // take last 15 bits of r
  end

  always_ff @( posedge clk )
  begin:
    r_n <= {d_i, r_s} // append d_i to r
    d_o <= r_n[0] ^ r_n[2] ^ r_n[3] ^ r_n[5];
  end

endmodule: lsfr

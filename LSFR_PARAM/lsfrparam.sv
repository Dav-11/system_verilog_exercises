module lsfrparam #(parameter IN_BIT = 1) (d_i, d_o, clk, rss);

  input   logic                 clk;
  input   logic                 rss;
  input   logic [IN_BIT-1:0]    d_i;
  output  logic [IN_BIT-1:0]    d_o;

  logic [IN_BIT-1:0] [15:0] r;
  logic [IN_BIT-1:0] [15:0] r_n;
  logic [IN_BIT-1:0] [14:0] r_s;

  always_ff @( posedge clk )
  begin:

    generate
      genvar i;
      for (i=0; i < IN_BIT; i++) begin

        if (rss) begin

          r_n[i] <= 16'h1001;
        end else begin

            r_s[i] <= r[i] >> 1;
            r_n[i] <= {d_i[i], r_s[i]};
            d_o[i] <= r_n[i][0] ^ r_n[i][2] ^ r_n[i][3] ^ r_n[i][5];
        end

      end
    endgenerate

  end

endmodule: lsfrparam

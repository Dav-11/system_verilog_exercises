module rr_arbiter #(
    parameter int N = 4
) (
    input  logic         clk,
    input  logic         rst,
    input  logic [N-1:0] req,
    output logic [N-1:0] grant
);

  logic [$clog2(N)-1:0] last_grant_idx;
  logic [N-1:0] rotated_req, rotated_grant;

  // Rotate requests so we start checking from (last_grant + 1)
  assign rotated_req = {req, req} >> (last_grant_idx + 1);

  // Priority encode the rotated request
  always_comb begin
    rotated_grant = '0;
    foreach (rotated_req[i]) begin
      if (rotated_req[i]) begin
        rotated_grant[i] = 1;
        break;
      end
    end
  end

  // Rotate grant back to original position
  assign grant = (rotated_grant << (last_grant_idx + 1)) |
                   (rotated_grant >> (N - (last_grant_idx + 1)));

  // Update last_grant pointer
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      last_grant_idx <= 0;
    end else if (grant != 0) begin
      last_grant_idx <= $clog2(grant);
    end
  end

endmodule

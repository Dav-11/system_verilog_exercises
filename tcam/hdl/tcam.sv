module tcam #(
    parameter WIDTH = 32,
    parameter DEPTH = 16
)(
    input  logic                  clk,
    input  logic                  we,
    input  logic [$clog2(DEPTH)-1:0] wr_addr,

    input  logic [WIDTH-1:0]      wr_data,
    input  logic [WIDTH-1:0]      wr_mask,

    input  logic [WIDTH-1:0]      search_key,

    output logic                  match,
    output logic [$clog2(DEPTH)-1:0] match_addr
);

logic [WIDTH-1:0] mem_data [DEPTH];
logic [WIDTH-1:0] mem_mask [DEPTH];

logic [DEPTH-1:0] match_vec;

integer i;

always_ff @(posedge clk) begin
    if (we) begin
        mem_data[wr_addr] <= wr_data;
        mem_mask[wr_addr] <= wr_mask;
    end
end

always_comb begin
    for (i = 0; i < DEPTH; i++) begin
        match_vec[i] =
            ((search_key & mem_mask[i]) ==
             (mem_data[i] & mem_mask[i]));
    end
end

always_comb begin
    match = 0;
    match_addr = '0;

    for (i = 0; i < DEPTH; i++) begin
        if (match_vec[i] && !match) begin
            match = 1;
            match_addr = i;
        end
    end
end

endmodule
module main_mem #(
    parameter int DW = 256,
    parameter int AW = 32,   // 1GB address space (512MB is 29 bits)

    localparam int BytesPerWord = DW / 8,
    localparam int WordAW = AW - $clog2(BytesPerWord)  // address width for each word
) (
    input logic clk,
    input logic rst_n,

    input logic              write_enable,
    input logic [    AW-1:0] write_addr,
    input logic [    DW-1:0] write_data,
    input logic [(DW/8)-1:0] write_sel,

    input  logic [    AW-1:0] read_addr,
    input  logic [(DW/8)-1:0] read_sel,
    output logic [    DW-1:0] read_data
);

  // memory as array of 2^AW bytes
  logic [(DW)-1:0] mem[(2**WordAW)-1:0];

  logic [WordAW-1:0] write_word_addr;
  logic [WordAW-1:0] read_word_addr;

  assign write_word_addr = write_addr[AW-1:$clog2(BytesPerWord)];
  assign read_word_addr  = read_addr[AW-1:$clog2(BytesPerWord)];

  // write port
  always_ff @(posedge clk) begin

    // write port
    if (write_enable) begin
      for (int i = 0; i < BytesPerWord; i++) begin
        if (write_sel[i]) begin
          mem[write_word_addr][i*8+:8] <= write_data[i*8+:8];
        end
      end
    end
  end


  // read port
  always_ff @(posedge clk) begin
    // read port
    for (int i = 0; i < BytesPerWord; i++) begin
      if (read_sel[i]) begin
        read_data[i*8+:8] <= mem[read_word_addr][i*8+:8];
      end
    end
  end

  initial begin
    $display("Setting main mem to 0...");
    for (integer i = 0; i < (2 ** WordAW); i++) mem[i] = '0;
    $display("done.");
  end

endmodule : main_mem

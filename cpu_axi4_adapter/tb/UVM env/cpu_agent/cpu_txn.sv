class cpu_txn extends uvm_sequence_item;

  rand bit we;
  rand bit [31:0] addr;
  rand bit [63:0] wdata;
  rand bit [7:0] sel;

  bit [63:0] rdata;

  `uvm_object_utils(cpu_txn)

  function new(string name="cpu_txn");
    super.new(name);
  endfunction

endclass
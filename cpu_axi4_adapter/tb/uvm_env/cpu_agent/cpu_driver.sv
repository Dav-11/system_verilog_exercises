class cpu_driver extends uvm_driver #(cpu_txn);

  virtual cpu_if vif;

  `uvm_component_utils(cpu_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    cpu_txn tx;

    forever begin

      seq_item_port.get_next_item(tx);

      vif.req <= 1;
      vif.we <= tx.we;
      vif.addr <= tx.addr;
      vif.wdata <= tx.wdata;
      vif.sel <= tx.sel;

      @(posedge vif.clk);

      vif.req <= 0;

      wait (vif.ack);

      tx.rdata = vif.rdata;

      seq_item_port.item_done();

    end

  endtask
endclass

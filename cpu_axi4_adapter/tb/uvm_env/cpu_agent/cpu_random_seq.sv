class cpu_random_seq extends uvm_sequence #(cpu_txn);

  `uvm_object_utils(cpu_random_seq)

  task body();

    cpu_txn tx;

    repeat (100) begin

      tx = cpu_txn::type_id::create("tx");

      assert (tx.randomize());

      start_item(tx);
      finish_item(tx);

    end

  endtask

endclass

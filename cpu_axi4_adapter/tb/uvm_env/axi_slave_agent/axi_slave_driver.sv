class axi_slave_driver extends uvm_component;

  virtual axi_if vif;

  bit [255:0] mem [0:1023];

  `uvm_component_utils(axi_slave_driver)

  task run_phase(uvm_phase phase);

    forever begin

      @(posedge vif.clk);

      vif.aw_ready <= 1;
      vif.w_ready <= 1;
      vif.ar_ready <= 1;

      // WRITE
      if(vif.aw_valid && vif.w_valid) begin

        mem[vif.aw_addr >> 5] = vif.w_data;

        vif.b_valid <= 1;
        vif.b_resp <= 0;

      end
      else begin
        vif.b_valid <= 0;
      end

      // READ
      if(vif.ar_valid) begin

        vif.r_valid <= 1;
        vif.r_last <= 1;
        vif.r_resp <= 0;
        vif.r_data <= mem[vif.ar_addr >> 5];

      end
      else begin
        vif.r_valid <= 0;
      end

    end

  endtask

endclass

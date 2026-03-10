// AXI3 Slave Adapter for a Dual-Port RAM (e.g., HBM Pseudo Channel)

module axi3_hbm_channel_mock #(
    // AXI Standard Parameters (256-bit HBM default)
    parameter int AXI_ID_WIDTH = 8,
    parameter int AXI_DATA_WIDTH = 256,
    parameter int AW = 32,  // 1GB address space (512MB is 29 bits)

    parameter int DELAY_W = 20,
    parameter int DELAY_R = 20
) (
    input logic clk,
    input logic rst_n,

    // --- AXI3 Slave Interface Signals (Connects to AXI Master) ---
    // Write Address Channel (AW)
    input  logic [AXI_ID_WIDTH-1:0] aw_id,
    input  logic [          AW-1:0] aw_addr,
    input  logic [             7:0] aw_len,    // beats = AWLEN + 1
    input  logic [             2:0] aw_size,
    input  logic [             1:0] aw_burst,  // 01 = INCR, 10 = WRAP, 00 = FIXED
    input  logic                    aw_valid,
    output logic                    aw_ready,

    // Write Data Channel (W)
    input  logic [      AXI_ID_WIDTH-1:0] w_id,
    input  logic [    AXI_DATA_WIDTH-1:0] w_data,
    input  logic [(AXI_DATA_WIDTH/8)-1:0] w_strb,
    input  logic                          w_last,
    input  logic                          w_valid,
    output logic                          w_ready,

    // Write Response Channel (B)
    output logic [AXI_ID_WIDTH-1:0] b_id,
    output logic [             1:0] b_resp,
    output logic                    b_valid,
    input  logic                    b_ready,

    // Read Address Channel (AR)
    input  logic [AXI_ID_WIDTH-1:0] ar_id,
    input  logic [          AW-1:0] ar_addr,
    input  logic [             7:0] ar_len,
    input  logic [             1:0] ar_burst,  // 01 = INCR, 10 = WRAP, 00 = FIXED
    input  logic                    ar_valid,
    output logic                    ar_ready,

    // Read Data Channel (R)
    output logic [  AXI_ID_WIDTH-1:0] r_id,
    output logic [AXI_DATA_WIDTH-1:0] r_data,
    output logic [               1:0] r_resp,
    output logic                      r_last,
    output logic                      r_valid,
    input  logic                      r_ready
);

  /*******************
   * MEMORY
   *******************/

  // control signals for mem
  logic mem_w_enable_r, mem_w_enable_next;
  logic [AW-1:0] mem_w_addr_r, mem_w_addr_next;
  logic [AXI_DATA_WIDTH-1:0] mem_w_data_r, mem_w_data_next;
  logic [(AXI_DATA_WIDTH/8)-1:0] mem_w_strb_r, mem_w_strb_next;

  logic [AW-1:0] mem_r_addr, mem_r_addr_old;
  logic [AXI_DATA_WIDTH-1:0] mem_r_data;
  logic [(AXI_DATA_WIDTH/8)-1:0] mem_r_strb;

  always_ff @(posedge clk) begin
    if (!rst_n) begin

      mem_w_enable_r <= '0;
      mem_w_addr_r   <= '0;
      mem_w_data_r   <= '0;
      mem_w_strb_r   <= '0;

      mem_r_addr_old <= '0;
    end else begin

      mem_w_enable_r <= mem_w_enable_next;
      mem_w_addr_r   <= mem_w_addr_next;
      mem_w_data_r   <= mem_w_data_next;
      mem_w_strb_r   <= mem_w_strb_next;

      mem_r_addr_old <= mem_r_addr;
    end
  end


  main_mem #(
      .DW(AXI_DATA_WIDTH),
      .AW(AW)
  ) mem (
      .clk  (clk),
      .rst_n(rst_n),

      .write_enable(mem_w_enable_r),
      .write_addr(mem_w_addr_r),
      .write_data(mem_w_data_r),
      .write_sel(mem_w_strb_r),

      .read_addr(mem_r_addr),
      .read_sel (mem_r_strb),
      .read_data(mem_r_data)
  );


  /***********************************************
   * Write FSM (Port A) (channels AW,W,B)
   ***********************************************/

  typedef enum logic [1:0] {
    W_ADDR_RX,
    W_DATA_RX,
    W_RESP_TX,
    W_DELAY
  } write_state_e;

  // internal registers
  write_state_e wr_state_r, wr_state_next;
  logic [AXI_ID_WIDTH-1:0] wr_id_r, wr_id_next;
  logic [AW-1:0] wr_addr_r, wr_addr_next;
  logic [7:0] wr_len_r, wr_len_next;
  logic [2:0] wr_size_r, wr_size_next;
  logic [1:0] wr_burst_r, wr_burst_next;

  logic [$clog2(DELAY_W)-1:0] wr_delay_cnt_r, wr_delay_cnt_next;

  // registered outputs
  logic aw_ready_r, aw_ready_next;
  logic w_ready_r, w_ready_next;
  logic [AXI_ID_WIDTH-1:0] b_id_r, b_id_next;
  logic [1:0] b_resp_r, b_resp_next;
  logic b_valid_r, b_valid_next;

  // assign outputs
  assign aw_ready = aw_ready_r;
  assign w_ready = w_ready_r;
  assign b_id = b_id_r;
  assign b_resp = b_resp_r;
  assign b_valid = b_valid_r;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      wr_state_r     <= W_ADDR_RX;
      wr_id_r        <= '0;
      wr_addr_r      <= '0;
      wr_len_r       <= '0;
      wr_size_r      <= '0;
      wr_burst_r     <= '0;
      wr_delay_cnt_r <= '0;

      aw_ready_r     <= '0;
      w_ready_r      <= '0;
      b_id_r         <= '0;
      b_resp_r       <= '0;
      b_valid_r      <= '0;

    end else begin
      wr_state_r     <= wr_state_next;
      wr_id_r        <= wr_id_next;
      wr_addr_r      <= wr_addr_next;
      wr_len_r       <= wr_len_next;
      wr_size_r      <= wr_size_next;
      wr_burst_r     <= wr_burst_next;
      wr_delay_cnt_r <= wr_delay_cnt_next;

      aw_ready_r     <= aw_ready_next;
      w_ready_r      <= w_ready_next;
      b_id_r         <= b_id_next;
      b_resp_r       <= b_resp_next;
      b_valid_r      <= b_valid_next;
    end
  end

  always_comb begin

    // defaults to 0 so that every different signals is explicitly set inside CASE
    aw_ready_next     = '0;
    w_ready_next      = '0;
    b_id_next         = '0;
    b_resp_next       = '0;
    b_valid_next      = '0;

    wr_state_next     = wr_state_r;
    wr_id_next        = '0;
    wr_addr_next      = '0;
    wr_len_next       = '0;
    wr_burst_next     = '0;
    wr_size_next      = '0;
    wr_delay_cnt_next = '0;

    mem_w_enable_next = '0;
    mem_w_addr_next   = '0;
    mem_w_data_next   = '0;
    mem_w_strb_next   = '0;


    // FSM
    unique case (wr_state_r)

      W_ADDR_RX: begin

        // wait for master to be ready
        aw_ready_next = 1;

        // if axi handshake -> read AR and wait for data
        if (aw_ready_r && aw_valid) begin

          wr_id_next    = aw_id;
          wr_addr_next  = aw_addr;
          wr_len_next   = aw_len;
          wr_burst_next = aw_burst;
          wr_size_next  = aw_size;

          // next state logic
          wr_state_next = W_DATA_RX;
          aw_ready_next = '0;
        end
      end

      W_DATA_RX: begin

        // wait for master to be ready
        w_ready_next = 1;

        // cycle internal registers to keep data
        wr_id_next    = wr_id_r;
        wr_addr_next  = wr_addr_r;
        wr_len_next   = wr_len_r;
        wr_burst_next = wr_burst_r;
        wr_size_next  = wr_size_r;

        if (w_ready_r && w_valid) begin

          // enable WRITE to mem (write is handled in mem code)
          mem_w_enable_next = 1;
          mem_w_addr_next   = wr_addr_r;
          mem_w_data_next   = w_data;
          mem_w_strb_next   = w_strb;

          if (w_last) begin

            // next state logic
            wr_state_next = W_DELAY;
            w_ready_next  = '0;

          end else begin

            if (wr_burst_r == 2'b01) begin

              // if burst is incremental, increment address
              wr_addr_next = wr_addr_r + (AXI_DATA_WIDTH / 8);
            end

            // update len
            wr_len_next = wr_len_r - 1;
          end
        end
      end

      W_DELAY: begin

        if (wr_delay_cnt_r >= DELAY_W - 1) begin

          // end of delay -> send response
          wr_state_next = W_RESP_TX;
        end else begin

          wr_delay_cnt_next = wr_delay_cnt_r + 1;
        end
      end

      W_RESP_TX: begin

        // wait for slave to be ready
        b_valid_next = 1;
        b_resp_next  = '0;  //OK
        b_id_next    = wr_id_r;

        // cycle internal registers to keep data
        wr_id_next   = wr_id_r;

        if (b_valid_r && b_ready) begin

          // next state logic
          b_valid_next  = 0;
          wr_state_next = W_ADDR_RX;
        end
      end
    endcase
  end


  /***********************************************
   * Read FSM (Port B) (channels AR,R)
   ***********************************************/
  typedef enum logic [1:0] {
    R_ADDR_RX,
    R_DELAY,
    R_DATA_TX,
    R_DATA_LAST
  } read_state_e;

  // internal registers
  read_state_e rd_state_r, rd_state_next;
  logic [AW-1:0] rd_addr_r, rd_addr_next;
  logic [7:0] rd_len_r, rd_len_next;
  logic [AXI_ID_WIDTH-1:0] rd_id_r, rd_id_next;
  logic [1:0] rd_burst_r, rd_burst_next;

  logic [$clog2(DELAY_R)-1:0] rd_delay_cnt_r, rd_delay_cnt_next;

  // registered outputs
  logic ar_ready_r, ar_ready_next;
  logic [AXI_ID_WIDTH-1:0] r_id_r, r_id_next;
  logic [AXI_DATA_WIDTH-1:0] r_data_r, r_data_next;
  logic [1:0] r_resp_r, r_resp_next;
  logic r_last_r, r_last_next;
  logic r_valid_r, r_valid_next;

  // assign outputs
  assign ar_ready = ar_ready_r;
  assign r_id = r_id_r;
  assign r_data = r_data_r;
  assign r_resp = r_resp_r;
  assign r_last = r_last_r;
  assign r_valid = r_valid_r;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      rd_state_r     <= R_ADDR_RX;
      rd_addr_r      <= '0;
      rd_len_r       <= '0;
      rd_id_r        <= '0;
      rd_burst_r     <= '0;
      rd_delay_cnt_r <= '0;

      ar_ready_r     <= '0;
      r_id_r         <= '0;
      r_data_r       <= '0;
      r_resp_r       <= '0;
      r_last_r       <= '0;
      r_valid_r      <= '0;
    end else begin
      rd_state_r     <= rd_state_next;
      rd_delay_cnt_r <= rd_delay_cnt_next;
      rd_addr_r      <= rd_addr_next;
      rd_len_r       <= rd_len_next;
      rd_id_r        <= rd_id_next;
      rd_burst_r     <= rd_burst_next;

      ar_ready_r     <= ar_ready_next;
      r_id_r         <= r_id_next;
      r_data_r       <= r_data_next;
      r_resp_r       <= r_resp_next;
      r_last_r       <= r_last_next;
      r_valid_r      <= r_valid_next;
    end
  end

  always_comb begin

    ar_ready_next     = '0;
    r_id_next         = '0;
    r_data_next       = '0;
    r_resp_next       = '0;
    r_last_next       = '0;
    r_valid_next      = '0;

    rd_state_next     = rd_state_r;
    rd_delay_cnt_next = '0;
    rd_id_next        = '0;
    rd_addr_next      = '0;
    rd_len_next       = '0;
    rd_burst_next     = '0;

    mem_r_addr        = '0;
    mem_r_strb        = '1;

    unique case (rd_state_r)
      R_ADDR_RX: begin

        ar_ready_next = 1'b1;

        if (ar_ready_r && ar_valid) begin

          // read AR channel
          rd_id_next = ar_id;
          rd_addr_next = ar_addr;
          rd_len_next = ar_len;
          rd_burst_next = ar_burst;

          // next state logic
          rd_state_next = R_DELAY;
          ar_ready_next = 1'b0;
        end
      end

      R_DELAY: begin

        rd_delay_cnt_next = rd_delay_cnt_r;
        rd_id_next        = rd_id_r;
        rd_addr_next      = rd_addr_r;
        rd_len_next       = rd_len_r;
        rd_burst_next     = rd_burst_r;

        // send 1st req to mem
        mem_r_addr        = rd_addr_r;

        if (rd_delay_cnt_r >= DELAY_R - 1) begin

          // send 2nd req to mem
          mem_r_addr    = rd_addr_r + (AXI_DATA_WIDTH / 8);

          // read data from mem
          r_data_next = mem_r_data;

          // next state logic
          rd_state_next = R_DATA_TX;
        end else begin

          // increment counter
          rd_delay_cnt_next = rd_delay_cnt_r + 1;
        end
      end

      R_DATA_TX: begin

        rd_id_next    = rd_id_r;
        rd_addr_next  = rd_addr_r;
        rd_len_next   = rd_len_r;
        rd_burst_next = rd_burst_r;

        r_id_next     = rd_id_r;
        r_valid_next  = 1'b1;

        mem_r_addr    = rd_addr_r + (AXI_DATA_WIDTH / 8);

        r_data_next   = r_data_r;

        if (r_valid_r && r_ready) begin

          r_data_next = mem_r_data;

          if (rd_len_r == 1) begin

            // assert LAST
            r_last_next = 1'b1;
          end

          if (rd_len_r == 0) begin

            // next state logic
            r_valid_next  = 1'b0;
            rd_state_next = R_ADDR_RX;
          end else begin

            if (rd_burst_r == 2'b01) begin

              // if burst is incremental update address
              mem_r_addr = mem_r_addr_old + (AXI_DATA_WIDTH / 8);
            end

            // update len
            rd_len_next = rd_len_r - 1;
          end
        end
      end
    endcase
  end

endmodule : axi3_hbm_channel_mock

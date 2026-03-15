module cpu_axi4_adapter #(
    parameter int AW = 32,
    parameter int CPU_DW = 64,
    parameter int AXI_ID_WIDTH = 8,
    parameter int AXI_DATA_WIDTH = 256,
    parameter logic [AXI_ID_WIDTH-1:0] CPU_ID = '0
) (
    input logic clk,
    input logic rst_n,

    // ================= CPU SIDE =================
    input logic                  req,
    input logic                  we,
    input logic [        AW-1:0] addr,
    input logic [    CPU_DW-1:0] wdata,
    input logic [(CPU_DW/8)-1:0] sel,

    output logic [CPU_DW-1:0] rdata,
    output logic              ack,

    // ================= AXI MASTER SIDE =================

    // Write address
    output logic [AXI_ID_WIDTH-1:0] aw_id,
    output logic [          AW-1:0] aw_addr,
    output logic [             7:0] aw_len,
    output logic [             2:0] aw_size,
    output logic [             1:0] aw_burst,
    output logic                    aw_valid,
    input  logic                    aw_ready,

    // Write data
    output logic [    AXI_DATA_WIDTH-1:0] w_data,
    output logic [(AXI_DATA_WIDTH/8)-1:0] w_strb,
    output logic                          w_last,
    output logic                          w_valid,
    input  logic                          w_ready,

    // Write response
    input  logic [AXI_ID_WIDTH-1:0] b_id,
    input  logic [             1:0] b_resp,
    input  logic                    b_valid,
    output logic                    b_ready,

    // Read address
    output logic [AXI_ID_WIDTH-1:0] ar_id,
    output logic [          AW-1:0] ar_addr,
    output logic [             7:0] ar_len,
    output logic [             2:0] ar_size,
    output logic [             1:0] ar_burst,
    output logic                    ar_valid,
    input  logic                    ar_ready,

    // Read data
    input  logic [  AXI_ID_WIDTH-1:0] r_id,
    input  logic [AXI_DATA_WIDTH-1:0] r_data,
    input  logic [               1:0] r_resp,
    input  logic                      r_last,
    input  logic                      r_valid,
    output logic                      r_ready
);

  // ====================================================
  // Compile-time constraint
  // ====================================================

  initial begin
    if (CPU_DW > AXI_DATA_WIDTH) $error("cpu_axi4_adapter: CPU_DW must be <= AXI_DATA_WIDTH");
  end

  // ====================================================
  // Derived constants
  // ====================================================

  localparam int CPU_BYTES = CPU_DW / 8;
  localparam int AXI_BYTES = AXI_DATA_WIDTH / 8;

  localparam int CPU_BYTE_LSB = $clog2(CPU_BYTES);
  localparam int AXI_BYTE_LSB = $clog2(AXI_BYTES);

  // AXI size = log2(bytes per beat)
  localparam logic [2:0] AXI_SIZE = $clog2(AXI_BYTES);

  // Single beat
  localparam logic [7:0] AXI_BEAT_NUMBER = 8'd0;

  // ====================================================
  // States
  // ====================================================

  typedef enum logic [2:0] {
    IDLE,
    WRITE_ADDR,
    WRITE_DATA,
    WRITE_RESP,
    READ_ADDR,
    READ_DATA,
    ERROR
  } state_t;

  // ====================================================
  // Registers
  // ====================================================

  state_t state_r, state_n;

  logic [AW-1:0] addr_r, addr_n;
  logic [CPU_DW-1:0] wdata_r, wdata_n;
  logic [(CPU_DW/8)-1:0] sel_r, sel_n;

  logic [AXI_BYTE_LSB-CPU_BYTE_LSB-1:0] lane;


  always_ff @(posedge clk) begin
    if (!rst_n) begin

      state_r <= IDLE;

      addr_r  <= '0;
      wdata_r <= '0;
      sel_r   <= '0;

    end else begin

      state_r <= state_n;

      addr_r  <= addr_n;
      wdata_r <= wdata_n;
      sel_r   <= sel_n;
    end
  end

  always_comb begin

    // ======================================
    // DEFAULTS
    // ======================================

    // internal signals
    state_n  = state_r;
    lane     = addr_r[AXI_BYTE_LSB-1:CPU_BYTE_LSB];

    // input
    addr_n   = addr_r;
    wdata_n  = wdata_r;
    sel_n    = sel_r;

    // output

    aw_id    = CPU_ID;
    aw_addr  = {addr_r[AW-1:AXI_BYTE_LSB], {AXI_BYTE_LSB{1'b0}}};
    aw_len   = AXI_BEAT_NUMBER;
    aw_size  = AXI_SIZE;
    aw_burst = 2'b01;  // INCR
    aw_valid = 1'b0;

    w_data   = '0;
    w_strb   = '0;
    w_last   = 1'b0;
    w_valid  = 1'b0;

    b_ready  = 1'b0;

    ar_addr  = {addr_r[AW-1:AXI_BYTE_LSB], {AXI_BYTE_LSB{1'b0}}};
    ar_len   = AXI_BEAT_NUMBER;
    ar_size  = AXI_SIZE;
    ar_burst = 2'b01;  // INCR
    ar_valid = 1'b0;

    ack      = 1'b0;
    rdata    = '0;

    // ======================================
    // FSM
    // ======================================


    unique case (state_r)

      IDLE: begin

        // register request params
        addr_n  = addr;
        wdata_n = '0;
        sel_n   = sel;

        if (req) begin

          if (we) begin

            // start write tx
            state_n = WRITE_ADDR;
            wdata_n = wdata;
          end

          if (!we) begin

            // start read tx
            state_n = READ_ADDR;
          end
        end

      end
      WRITE_ADDR: begin

        aw_valid = 1'b1;

        if (aw_ready) begin
          state_n = WRITE_DATA;
        end

      end
      WRITE_DATA: begin

        w_valid = 1'b1;
        w_last = 1'b1;  // always 1 beat

        // Pack write data into AXI beat
        w_data[lane*CPU_DW+:CPU_DW] = wdata_r;
        w_strb[lane*CPU_BYTES+:CPU_BYTES] = sel_r;

        if (w_ready) begin
          state_n = WRITE_RESP;
        end
      end
      WRITE_RESP: begin

        b_ready = 1'b1;

        if (b_valid) begin

          if (b_resp == 2'b00 || b_resp == 2'b01) begin

            // complete tx
            ack = 1'b1;
            state_n = IDLE;
          end else begin

            // go to err state
            state_n = ERROR;
          end
        end
      end
      READ_ADDR: begin

        ar_valid = 1'b1;

        if (ar_ready) begin
          state_n = READ_DATA;
        end

      end
      READ_DATA: begin

        r_ready = 1'b1;

        if (r_valid) begin

          if (r_resp == 2'b00 || r_resp == 2'b01) begin

            rdata = r_data[lane*CPU_DW+:CPU_DW];

            if (r_last) begin
              ack = 1'b1;
              state_n = IDLE;
            end

          end else begin

            // go to err state
            state_n = ERROR;
          end

        end
      end
      ERROR: begin

      end
    endcase
  end


endmodule : cpu_axi4_adapter

onerror {resume}

quietly WaveActivateNextPane {} 0

# Top-level signals
add wave sim:/tb_axi4_mux/RR_PRIO_NUMBER
add wave sim:/tb_axi4_mux/FIXED_PRIO_NUMBER
add wave sim:/tb_axi4_mux/INPUT_NUMBER
add wave sim:/tb_axi4_mux/clk
add wave sim:/tb_axi4_mux/rst_n

# ================= READ =================
add wave -group READ

# READ.in
add wave -group {READ/in} sim:/tb_axi4_mux/dut/in_ar_id
add wave -group {READ/in} sim:/tb_axi4_mux/dut/in_ar_addr
add wave -group {READ/in} sim:/tb_axi4_mux/dut/in_ar_len
add wave -group {READ/in} sim:/tb_axi4_mux/dut/in_ar_size
add wave -group {READ/in} sim:/tb_axi4_mux/dut/in_ar_burst
add wave -group {READ/in} sim:/tb_axi4_mux/dut/in_ar_valid
add wave -group {READ/in} sim:/tb_axi4_mux/dut/in_ar_ready

add wave -group {READ/in} sim:/tb_axi4_mux/dut/in_r_id
add wave -group {READ/in} sim:/tb_axi4_mux/dut/in_r_data
add wave -group {READ/in} sim:/tb_axi4_mux/dut/in_r_resp
add wave -group {READ/in} sim:/tb_axi4_mux/dut/in_r_last
add wave -group {READ/in} sim:/tb_axi4_mux/dut/in_r_valid
add wave -group {READ/in} sim:/tb_axi4_mux/dut/in_r_ready

# READ.out
add wave -group {READ/out} sim:/tb_axi4_mux/dut/out_ar_id
add wave -group {READ/out} sim:/tb_axi4_mux/dut/out_ar_addr
add wave -group {READ/out} sim:/tb_axi4_mux/dut/out_ar_len
add wave -group {READ/out} sim:/tb_axi4_mux/dut/out_ar_size
add wave -group {READ/out} sim:/tb_axi4_mux/dut/out_ar_burst
add wave -group {READ/out} sim:/tb_axi4_mux/dut/out_ar_valid
add wave -group {READ/out} sim:/tb_axi4_mux/dut/out_ar_ready

add wave -group {READ/out} sim:/tb_axi4_mux/dut/out_r_id
add wave -group {READ/out} sim:/tb_axi4_mux/dut/out_r_data
add wave -group {READ/out} sim:/tb_axi4_mux/dut/out_r_resp
add wave -group {READ/out} sim:/tb_axi4_mux/dut/out_r_last
add wave -group {READ/out} sim:/tb_axi4_mux/dut/out_r_valid
add wave -group {READ/out} sim:/tb_axi4_mux/dut/out_r_ready

# READ.arb_r
add wave -group {READ/arb_r} sim:/tb_axi4_mux/dut/arb_r/in_ar_valid
add wave -group {READ/arb_r} sim:/tb_axi4_mux/dut/arb_r/out_ar_ready
add wave -group {READ/arb_r} sim:/tb_axi4_mux/dut/arb_r/rr_req
add wave -group {READ/arb_r} sim:/tb_axi4_mux/dut/arb_r/rr_has_req
add wave -group {READ/arb_r} sim:/tb_axi4_mux/dut/arb_r/fixed_req
add wave -group {READ/arb_r} sim:/tb_axi4_mux/dut/arb_r/fixed_has_req

add wave -group {READ/arb_r} sim:/tb_axi4_mux/dut/arb_r/out_r_valid
add wave -group {READ/arb_r} sim:/tb_axi4_mux/dut/arb_r/out_r_last
add wave -group {READ/arb_r} sim:/tb_axi4_mux/dut/arb_r/out_r_ready

add wave -group {READ/arb_r} sim:/tb_axi4_mux/dut/arb_r/state_n
add wave -group {READ/arb_r} sim:/tb_axi4_mux/dut/arb_r/state_r

# ================= WRITE =================
add wave -group WRITE

# WRITE.in
add wave -group {WRITE/in} sim:/tb_axi4_mux/dut/in_aw_id
add wave -group {WRITE/in} sim:/tb_axi4_mux/dut/in_aw_addr
add wave -group {WRITE/in} sim:/tb_axi4_mux/dut/in_aw_len
add wave -group {WRITE/in} sim:/tb_axi4_mux/dut/in_aw_size
add wave -group {WRITE/in} sim:/tb_axi4_mux/dut/in_aw_burst
add wave -group {WRITE/in} sim:/tb_axi4_mux/dut/in_aw_valid
add wave -group {WRITE/in} sim:/tb_axi4_mux/dut/in_aw_ready

add wave -group {WRITE/in} sim:/tb_axi4_mux/dut/in_w_data
add wave -group {WRITE/in} sim:/tb_axi4_mux/dut/in_w_strb
add wave -group {WRITE/in} sim:/tb_axi4_mux/dut/in_w_last
add wave -group {WRITE/in} sim:/tb_axi4_mux/dut/in_w_valid
add wave -group {WRITE/in} sim:/tb_axi4_mux/dut/in_w_ready

add wave -group {WRITE/in} sim:/tb_axi4_mux/dut/in_b_id
add wave -group {WRITE/in} sim:/tb_axi4_mux/dut/in_b_resp
add wave -group {WRITE/in} sim:/tb_axi4_mux/dut/in_b_valid
add wave -group {WRITE/in} sim:/tb_axi4_mux/dut/in_b_ready

# WRITE.out
add wave -group {WRITE/out} sim:/tb_axi4_mux/dut/out_aw_id
add wave -group {WRITE/out} sim:/tb_axi4_mux/dut/out_aw_addr
add wave -group {WRITE/out} sim:/tb_axi4_mux/dut/out_aw_len
add wave -group {WRITE/out} sim:/tb_axi4_mux/dut/out_aw_size
add wave -group {WRITE/out} sim:/tb_axi4_mux/dut/out_aw_burst
add wave -group {WRITE/out} sim:/tb_axi4_mux/dut/out_aw_valid
add wave -group {WRITE/out} sim:/tb_axi4_mux/dut/out_aw_ready

add wave -group {WRITE/out} sim:/tb_axi4_mux/dut/out_w_data
add wave -group {WRITE/out} sim:/tb_axi4_mux/dut/out_w_strb
add wave -group {WRITE/out} sim:/tb_axi4_mux/dut/out_w_last
add wave -group {WRITE/out} sim:/tb_axi4_mux/dut/out_w_valid
add wave -group {WRITE/out} sim:/tb_axi4_mux/dut/out_w_ready

add wave -group {WRITE/out} sim:/tb_axi4_mux/dut/out_b_id
add wave -group {WRITE/out} sim:/tb_axi4_mux/dut/out_b_resp
add wave -group {WRITE/out} sim:/tb_axi4_mux/dut/out_b_valid
add wave -group {WRITE/out} sim:/tb_axi4_mux/dut/out_b_ready

# WRITE.arb_w
add wave -group {WRITE/arb_w} sim:/tb_axi4_mux/dut/arb_w/in_aw_valid
add wave -group {WRITE/arb_w} sim:/tb_axi4_mux/dut/arb_w/out_aw_ready
add wave -group {WRITE/arb_w} sim:/tb_axi4_mux/dut/arb_w/rr_req
add wave -group {WRITE/arb_w} sim:/tb_axi4_mux/dut/arb_w/rr_has_req
add wave -group {WRITE/arb_w} sim:/tb_axi4_mux/dut/arb_w/fixed_req
add wave -group {WRITE/arb_w} sim:/tb_axi4_mux/dut/arb_w/fixed_has_req

add wave -group {WRITE/arb_w} sim:/tb_axi4_mux/dut/arb_w/out_b_valid
add wave -group {WRITE/arb_w} sim:/tb_axi4_mux/dut/arb_w/out_b_ready

add wave -group {WRITE/arb_w} sim:/tb_axi4_mux/dut/arb_w/state_n
add wave -group {WRITE/arb_w} sim:/tb_axi4_mux/dut/arb_w/state_r
add wave -group {WRITE/arb_w} sim:/tb_axi4_mux/dut/arb_w/sel_n
add wave -group {WRITE/arb_w} sim:/tb_axi4_mux/dut/arb_w/sel_r

# ================= RAM =================
add wave -group RAM

add wave -group {RAM/AW} sim:/tb_axi4_mux/ram/s_axi_awid
add wave -group {RAM/AW} sim:/tb_axi4_mux/ram/s_axi_awaddr
add wave -group {RAM/AW} sim:/tb_axi4_mux/ram/s_axi_awlen
add wave -group {RAM/AW} sim:/tb_axi4_mux/ram/s_axi_awsize
add wave -group {RAM/AW} sim:/tb_axi4_mux/ram/s_axi_awburst
add wave -group {RAM/AW} sim:/tb_axi4_mux/ram/s_axi_awlock
add wave -group {RAM/AW} sim:/tb_axi4_mux/ram/s_axi_awcache
add wave -group {RAM/AW} sim:/tb_axi4_mux/ram/s_axi_awprot
add wave -group {RAM/AW} sim:/tb_axi4_mux/ram/s_axi_awvalid
add wave -group {RAM/AW} sim:/tb_axi4_mux/ram/s_axi_awready

add wave -group {RAM/W} sim:/tb_axi4_mux/ram/s_axi_wdata
add wave -group {RAM/W} sim:/tb_axi4_mux/ram/s_axi_wstrb
add wave -group {RAM/W} sim:/tb_axi4_mux/ram/s_axi_wlast
add wave -group {RAM/W} sim:/tb_axi4_mux/ram/s_axi_wvalid
add wave -group {RAM/W} sim:/tb_axi4_mux/ram/s_axi_wready

add wave -group {RAM/B} sim:/tb_axi4_mux/ram/s_axi_bid
add wave -group {RAM/B} sim:/tb_axi4_mux/ram/s_axi_bresp
add wave -group {RAM/B} sim:/tb_axi4_mux/ram/s_axi_bvalid
add wave -group {RAM/B} sim:/tb_axi4_mux/ram/s_axi_bready
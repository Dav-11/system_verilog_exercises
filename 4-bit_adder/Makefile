# Makefile for adder simulation

# Source files
TOP := tb_adder
VERILOG_SOURCES := \
	tb_adder.sv \
	adder_if.sv \
	adder.sv

# Output directory for Verilator (optional, but good for cleanliness)
BUILD_DIR := .out

# Add the C++ main wrapper file
CXX_SOURCES := sim_main.cpp

.PHONY: all clean run view vcd

all: run

compile:
	mkdir -p $(BUILD_DIR)
	xvlog --sv $(VERILOG_SOURCES)

elaborate: compile
	xelab -debug typical $(TOP) -s $(TOP).sim

run: elaborate
	xsim $(TOP).sim -runall

dump.vcd: elaborate dump_vcd.tcl $(VERILOG_SOURCES)
	xsim $(TOP).sim -t dump_vcd.tcl

# Rule to view the VCD with GTKWave
view: dump.vcd
	@echo "--- Opening VCD with GTKWave ---"
	gtkwave dump.vcd &

# Rule to clean up generated files
clean:
	@echo "--- Cleaning up ---"
	rm -rf *.jou *.log *.pb xsim.dir *.sim $(BUILD_DIR)  *.wdb

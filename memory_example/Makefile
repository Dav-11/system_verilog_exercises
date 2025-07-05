# Makefile for adder simulation

# Source files
TOP := mem_hw
VERILOG_SOURCES := \
	hdl/param_pkg.sv \
	hdl/dp_ram_clk.sv \
	hdl/mem_hw.sv

MEM_FILE := my_mem_init.hex

# Output directory for Verilator (optional, but good for cleanliness)
BUILD_DIR := .out

.PHONY: all clean run view vcd

all: run

compile:
	mkdir -p $(BUILD_DIR)
	xvlog -d MEM_INIT_FILE="\"$(MEM_FILE)\"" --sv $(VERILOG_SOURCES) 

elaborate: compile
	xelab -debug typical $(TOP) -s $(TOP).sim -d MEM_INIT_FILE="\"$(MEM_FILE)\""

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

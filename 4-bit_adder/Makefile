# Makefile for 4-bit_adder simulation with Verilator

# Verilator options
VERILATOR_FLAGS := --cc --exe --trace --build --relative-includes --no-timing --Wno-fatal

# Source files
TOP_MODULE := tb_adder
VERILOG_SOURCES := \
	tb_adder.sv \
	adder_if.sv \
	adder.sv

# Output directory for Verilator (optional, but good for cleanliness)
BUILD_DIR := .out

# Add the C++ main wrapper file
CXX_SOURCES := sim_main.cpp

.PHONY: all clean run view

all: run

# Rule to compile and link with Verilator
$(BUILD_DIR)/V$(TOP_MODULE): $(VERILOG_SOURCES)
	@echo "--- Compiling with Verilator ---"
	verilator $(VERILATOR_FLAGS) \
		-y . \
		--Mdir $(BUILD_DIR) \
		--top-module $(TOP_MODULE) \
		$(VERILOG_SOURCES) \
		$(CXX_SOURCES) # Pass the C++ main file here

$(BUILD_DIR)/$(TOP_MODULE): $(VERILOG_SOURCES)
	iverilog -g2012 -o $@ $(VERILOG_SOURCES)
	vvp $@

# Rule to run the simulation
run: $(BUILD_DIR)/V$(TOP_MODULE)
	@echo "--- Running simulation ---"
	# Navigate into the build directory to run the generated executable
	$(BUILD_DIR)/V$(TOP_MODULE)

# Rule to view the VCD with GTKWave
view:
	@echo "--- Opening VCD with GTKWave ---"
	gtkwave $(BUILD_DIR)/$(TOP_MODULE).vcd &

# Rule to clean up generated files
clean:
	@echo "--- Cleaning up ---"
	rm -rf $(BUILD_DIR)
	rm -f *.vcd

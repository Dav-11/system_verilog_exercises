#################################
# VARS
#################################

TB       ?= tb_cpu_axi4_adapter

QUESTA   ?= vsim
QUESTA_UVM ?= /eda/Siemens/2024-25/RHELx86/QUESTA-CORE-PRIME_2024.3/questasim/verilog_src/uvm-1.2/src
VLOG     ?= vlog
VMAP     ?= vmap
VLIB     ?= vlib
WORK     ?= work

VLOG_FLAGS ?= -sv +acc
VSIM_FLAGS ?= -c -t 1ns -do "run -all; quit -f"

#################################
# SOURCE FILES
#################################

# Interfaces
TB_IF = \
	tb/cpu_if.sv \
	tb/axi4_if.sv

# DUT
DUT = \
	hdl/cpu_axi4_adapter.sv

# UVM ENV
UVM_ENV = $(shell find tb/uvm_env -name '*.sv')

# TB top
TB_TOP = \
	tb/tb_cpu_axi4_adapter.sv

# SRC = $(TB_IF) $(DUT) $(UVM_ENV) $(TB_TOP)
SRC = $(TB_IF) $(DUT) $(TB_TOP)

#################################
# TARGETS
#################################

.PHONY: all
all: vsim

#################################
# Questa Init
#################################

.PHONY: questa_init
questa_init:
	@$(VLIB) $(WORK) || true
	@$(VMAP) work $(WORK) || true

#################################
# Compile
#################################

# Compile UVM package first
.PHONY: uvm_build
uvm_build: questa_init
	$(VLOG) -sv +incdir+$(QUESTA_UVM) $(QUESTA_UVM)/uvm_pkg.sv

# Then compile DUT + TB + UVM files
.PHONY: questa_build
questa_build: questa_init #uvm_build
	$(VLOG) $(VLOG_FLAGS) +incdir+$(QUESTA_UVM) $(SRC)

#################################
# Run
#################################

.PHONY: questa_run
questa_run: questa_build
	$(QUESTA) $(VSIM_FLAGS) $(TB)

#################################
# Convenience
#################################

.PHONY: vsim
vsim: questa_run

#################################
# GUI
#################################

.PHONY: vsim_gui
vsim_gui: questa_build
	$(QUESTA) -t 1ns -do "log -r /*; run -all" $(TB)

#################################
# VCD
#################################

.PHONY: vsim_vcd
vsim_vcd: questa_build
	$(QUESTA) -c -t 1ns -do "vcd file waves.vcd; vcd add -r /*; run -all; quit -f" $(TB)

#################################
# Clean
#################################

.PHONY: clean
clean:
	rm -rf work transcript *.wlf *.vcd *.ucdb vsim_stacktrace.vstf

#################################
# Format
#################################

.PHONY: fmt
fmt:
	verible-verilog-format --inplace=true $$(find . -name "*.sv")
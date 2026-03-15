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

XRUN        ?= xrun
XRUN_FLAGS  ?= -sv -access +rwc -timescale 1ns/1ps
XRUN_GUI    ?= -gui

TOOL ?= questa

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
	tb/tb_cpu_axi4_adapter.sv \
	tb/axi_ram.sv

# SRC = $(TB_IF) $(DUT) $(UVM_ENV) $(TB_TOP)
SRC = $(TB_IF) $(DUT) $(TB_TOP)

#################################
# TARGETS
#################################

.PHONY: all
all: sim

#################################
# UNIFIED SIM TARGETS
#################################

.PHONY: sim
sim:
ifeq ($(TOOL),questa)
	$(MAKE) vsim
else ifeq ($(TOOL),xcelium)
	$(MAKE) xrun
else
	@echo "Unknown TOOL=$(TOOL)"
	@exit 1
endif


.PHONY: sim_gui
sim_gui:
ifeq ($(TOOL),questa)
	$(MAKE) vsim_gui
else ifeq ($(TOOL),xcelium)
	$(MAKE) xrun_gui
else
	@echo "Unknown TOOL=$(TOOL)"
	@exit 1
endif


.PHONY: sim_vcd
sim_vcd:
ifeq ($(TOOL),questa)
	$(MAKE) vsim_vcd
else ifeq ($(TOOL),xcelium)
	$(MAKE) xrun_vcd
else
	@echo "Unknown TOOL=$(TOOL)"
	@exit 1
endif

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
	$(QUESTA) -c -t 1ns -do "vcd file waves_questa.vcd; vcd add -r /*; run -all; quit -f" $(TB)

#################################
# Clean
#################################

.PHONY: clean
clean:
	rm -rf work transcript *.wlf *.vcd *.ucdb vsim_stacktrace.vstf

#################################
# Xcelium Build
#################################

.PHONY: xcelium_build
xcelium_build:
	$(XRUN) $(XRUN_FLAGS) -elaborate $(SRC) -top $(TB)

#################################
# Xcelium Run
#################################

.PHONY: xrun
xrun:
	$(XRUN) $(XRUN_FLAGS) $(SRC) -top $(TB)

#################################
# Xcelium GUI
#################################

.PHONY: xrun_gui
xrun_gui:
	$(XRUN) $(XRUN_FLAGS) $(XRUN_GUI) $(SRC) -top $(TB)

#################################
# Xcelium VCD
#################################

.PHONY: xrun_vcd
xrun_vcd:
	$(XRUN) $(XRUN_FLAGS) \
	-input "@database -open waves -vcd; probe -create -all -depth all; run; exit" \
	$(SRC) -top $(TB)

#################################
# Format
#################################

.PHONY: fmt
fmt:
	verible-verilog-format --inplace=true $$(find . -name "*.sv")


.PHONY: help
help:
	@echo "Commands:"
	@echo " fmt:        format all files"
	@echo ""
	@echo " sim:        run simulation (default TOOL=questa)"
	@echo " sim_gui:    run simulation with GUI"
	@echo " sim_vcd:    run simulation and dump VCD"
	@echo ""
	@echo " vsim:       simulate using QuestaSim (Siemens)"
	@echo " vsim_gui:   simulate using QuestaSim GUI"
	@echo " vsim_vcd:   simulate using QuestaSim and dump VCD"
	@echo " xrun:       simulate using Xcelium (Cadence)"
	@echo " xrun_gui:   simulate using Xcelium GUI"
	@echo " xrun_vcd:   simulate using Xcelium and dump VCD"

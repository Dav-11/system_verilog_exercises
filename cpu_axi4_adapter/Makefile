
#################################
# VARS
#################################


# Questa SIM (Override these if needed: e.g., make vsim TB=arbiter_tb)
TB       ?= arbiter_tb
QUESTA   ?= vsim            # set to full path if not on PATH
VLOG     ?= vlog
VMAP     ?= vmap
VLIB     ?= vlib
WORK     ?= work

# Common compile flags
# -sv enables SystemVerilog; +acc for signal access (waves); -timescale from source or override here
VLOG_FLAGS ?= -sv +acc

# Batch simulation (-c), run to completion, then quit
VSIM_FLAGS ?= -c -t 1ns -do "run -all; quit -f"

#################################
# TARGETS
#################################

all: fmt

# [Questa] 1 Prepare the work library
.PHONY: questa_init
questa_init:
	@$(VLIB) $(WORK) || true
	@$(VMAP) work $(WORK) || true

# [Questa] 2) Compile (analyze + elaborate)
.PHONY: questa_build
questa_build: questa_init
	@$(VLOG) $(VLOG_FLAGS) arbiter.sv arbiter_tb.sv

# [Questa] 3) Run batch simulation (non-GUI)
.PHONY: questa_run
questa_run: questa_build
	@$(QUESTA) $(VSIM_FLAGS) $(TB)

# [Questa] Convenience target: compile + run
.PHONY: vsim
vsim: questa_run

# [Questa] 4) GUI run with waves (logs all signals recursively)
.PHONY: vsim_gui
vsim_gui: questa_build
	@$(QUESTA) -t 1ns -do "log -r /*; run -all" $(TB)

# [Questa] 5) Produce a VCD (if you prefer VCD instead of .wlf)
#    Questa can write VCD via vsim commands; no code changes needed.
.PHONY: vsim_vcd
vsim_vcd: questa_build
	@$(QUESTA) -c -t 1ns -do "vcd file arbiter.vcd; vcd add -r /*; run -all; vcd flush; quit -f" $(TB)

# [Questa] 6) Coverage (UCDB); opens GUI report at the end
COV_LIB   ?= cov_work
.PHONY: vsim_cov
vsim_cov: questa_init
	@$(VLOG) $(VLOG_FLAGS) +cover=bcesft -coveropt 3 arbiter.sv arbiter_tb.sv
	@$(QUESTA) -c -coverage -t 1ns -do "run -all; coverage report -details -cvg -codeAll -output coverage.txt; quit -f" $(TB)
	@echo "Coverage report written to coverage.txt"

# [Questa] 7) Clean Questa artifacts
.PHONY: clean_questa
clean_questa:
	@rm -rf $(WORK) $(COV_LIB) transcript *.wlf *.ucdb vsim_stacktrace.vstf covhtmlreport coverage.txt arbiter.vcd


.PHONY: fmt
fmt: 
	verible-verilog-format --inplace=true **/*.sv

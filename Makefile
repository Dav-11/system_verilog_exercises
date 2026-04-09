

all: fmt

#################################
# Format
#################################

.PHONY: fmt
fmt:
	verible-verilog-format --inplace=true $$(find . -name "*.sv")
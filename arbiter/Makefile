all: build view

build:
	iverilog -g2012 -o arbiter arbiter_tb.sv arbiter.sv

view:
	sootty "arbiter.vcd" -o > arbiter.svg
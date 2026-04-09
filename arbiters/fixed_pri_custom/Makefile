all: build run

build:
	iverilog -g2012 -o arbiter arbiter_tb.sv arbiter.sv

run:
	vvp arbiter

view:
	sootty "arbiter.vcd" -o > arbiter.svg

.PHONY: sym
sym:
	@gcc -o sym sym.c
	@./sym

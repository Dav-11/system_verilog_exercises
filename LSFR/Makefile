all:
	iverilog -g2012 -o lsfr lsfr_tb.sv lsfr.sv

view:
	$(MAKE)
	sootty "lsfr.vcd" -o > lsfr.svg
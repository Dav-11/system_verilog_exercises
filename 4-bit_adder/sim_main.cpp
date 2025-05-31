// sim_main.cpp
#include <iostream>
#include <verilated.h>          // Common Verilator headers
#include <verilated_vcd_c.h>    // For VCD tracing

// Include the header of your top-level Verilator model
// This name is derived from your TOP_MODULE (tb_adder)
#include "Vtb_adder.h"

// Current simulation time (in arbitrary units)
vluint64_t main_time = 0;

// Called by $time in Verilog
double sc_time_stamp() {
    return main_time;
}

int main(int argc, char** argv, char** env) {
    // Prevent unused variable warnings
    if (false && argc && argv && env) {}

    // Set debug level, 0 is off, 9 is highest
    Verilated::debug(0);

    // Randomization reset (for SystemVerilog random functions)
    Verilated::randReset(2);

    // Construct the Verilated model, from Vtb_adder.h
    Vtb_adder* top = new Vtb_adder;

    // Enable VCD tracing
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99); // Trace 99 levels of hierarchy
    tfp->open("tb_adder.vcd"); // Open the VCD file

    // Main simulation loop
    while (!Verilated::gotFinish() && main_time < 100) { // Simulate for 100 time units
        // Evaluate model
        top->eval();

        // Dump VCD data
        tfp->dump(main_time);

        // Advance time
        main_time++;
    }

    // Close VCD file
    tfp->close();

    // Clean up model
    delete top;
    delete tfp;

    // Final model cleanup
    Verilated::flushCall();
    Verilated::commandArgs(argc, argv); // For command line arguments
    return 0;
}

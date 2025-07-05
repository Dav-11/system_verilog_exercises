// Memory module with port width of a full cache line, is it ok?
import param_pkg::*;

module mem_hw (
    input clk,
    input rcyc,
    input wcyc,
    input [MAIN_MEM_AW-1:0] waddr,
    input [MAIN_MEM_AW-1:0] raddr,
    input [MAIN_MEM_DW-1:0] wdata,
    output logic [MAIN_MEM_DW-1:0] rdata
);

    // The DPRAM_AW parameter is hardcoded to 32 in order to allow synth as a BRAM
    dp_ram_clk #(.DPRAM_AW(MAIN_MEM_AW), .DPRAM_DW(MAIN_MEM_DW))
            main_memory (
            .clk        (clk),

            // Always read on port A
            .cyc_a_i    (rcyc),
            .we_a_i     (1'b0),
            .adr_a_i    (raddr),
            .dat_a_i    ('0),

            // Always write on port B
            .cyc_b_i    (wcyc),
            .we_b_i     (1'b1),
            .adr_b_i    (waddr),
            .dat_b_i    (wdata),

            .dat_a_o    (rdata),
            .dat_b_o    ()
        );



    // `ifndef SYNTHESIS
    //     initial begin

    //         `ifdef MEM_INIT_FILE
    //             int fd;
    //             $display("This is 2 core version!");
    //             $write("Grabbing memory file path...");
    //             fd = $fopen(`MEM_INIT_FILE, "r");
    //             if (!fd) begin
    //                 $display("Error");
    //                 $display("Couldn't open %s, continuing with no mem file", `MEM_INIT_FILE);
    //             end else begin
    //                 $fgets(`MEM_INIT_FILE, fd);
    //                 $fclose(fd);
    //                 // Detect and remove trailing newline
    //                 // if (`MEM_INIT_FILE.getc(`MEM_INIT_FILE.len()-1) == "\n") begin
    //                 //     `MEM_INIT_FILE = `MEM_INIT_FILE.substr(0, `MEM_INIT_FILE.len()-2);
    //                 // end

    //                 // Test if file exists
    //                 fd = $fopen(`MEM_INIT_FILE, "r");
    //                 if (!fd) begin
    //                     $display("Error");
    //                     $display("File path %s is invalid, continuing with no mem file", `MEM_INIT_FILE);
    //                 end else begin
    //                     $fclose(fd);
    //                     $display("Done");
    //                     $write("Reading memory from file: %s...", `MEM_INIT_FILE);
    //                     $fflush();
    //                     $readmemh(`MEM_INIT_FILE, main_memory.mem);
    //                     $display("Done");
    //                 end
    //             end
    //         `else
    //             $display("No memory init file provided (define MEM_INIT_FILE)");
    //         `endif
    //     end
    // `endif

    // Use synthesis-time defined macro for the memory file path
    `ifndef SYNTHESIS
    initial begin
        `ifdef MEM_INIT_FILE
            $display("Loading memory from file: %s", `MEM_INIT_FILE);
            $readmemh(`MEM_INIT_FILE, main_memory.mem);
        `else
            $display("No memory init file provided (define MEM_INIT_FILE)");
        `endif
    end
    `endif

endmodule

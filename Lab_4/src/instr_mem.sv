/*
 * Instruction Memory (IROM)
 * Provides the 32-bit machine code at the given PC address.
 */
module instr_mem
(
    input  logic [31:0] addr,
    output logic [31:0] instr
);

    logic [31:0] rom [0:255]; // 256 words of memory

    // // Load machine code from a hex file (created during assembly)
    // initial begin
    //     $readmemh("program.hex", rom);
    // end

    // Asynchronous read: Instruction is available immediately
    // Note: PC is byte-addressed, but memory is word-aligned (addr >> 2)
    assign instr = rom[addr[31:2]];

endmodule
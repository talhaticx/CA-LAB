/*
 * Data Memory
 * Synchronous write for 'sw' and asynchronous read for 'lw'.
 */
module data_mem
(
    input  logic        clk,
    input  logic        mem_write,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

    logic [31:0] memory [0:1024] = '{default: '0};

    // Synchronous Write
    always_ff @(posedge clk) begin
        if (mem_write) begin
            memory[addr[31:2]] <= write_data;
        end
    end

    // Asynchronous Read
    assign read_data = memory[addr[31:2]];

    
endmodule
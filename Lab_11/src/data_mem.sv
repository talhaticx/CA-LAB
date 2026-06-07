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

    logic [31:0] memory [1024] = '{default: '0};

    // Initialize array: {2, 4, 1, 3}
    initial begin
        memory[0] = 32'd2;
        memory[1] = 32'd4;
        memory[2] = 32'd1;
        memory[3] = 32'd3;
    end

    // Synchronous Write
    always_ff @(posedge clk) begin
        if (mem_write) begin
            memory[addr[11:2]] <= write_data;
        end
    end

    // Asynchronous Read
    assign read_data = memory[addr[11:2]];

    
endmodule
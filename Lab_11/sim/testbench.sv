`timescale 1ns/1ps

module testbench;

    // Signals
    logic clk;
    logic rst;

    // Instantiate the Top-Level 3-Stage Pipeline
    three_stage_pipeline dut (
        .clk(clk),
        .rst(rst)
    );

    // Clock Generation (10ns period -> 100MHz)
    always #5 clk = ~clk;

    // Test Sequence
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        // Initialize signals
        clk = 0;
        rst = 1;

        // Apply reset for one clock cycle
        #10;
        rst = 0;
        

        // Wait for the sorting algorithm to execute
        // A 4-element insertion sort will easily finish within a few hundred cycles.
        // We will wait 500 cycles (5000ns) to be safe.
        #5000;

        // Display the final contents of the Data Memory
        $display("\n========================================");
        $display("          INSERTION SORT RESULTS        ");
        $display("========================================");
        $display("Memory[0] = %0d", dut.d_mem.memory[0]);
        $display("Memory[1] = %0d", dut.d_mem.memory[1]);
        $display("Memory[2] = %0d", dut.d_mem.memory[2]);
        $display("Memory[3] = %0d", dut.d_mem.memory[3]);
        $display("========================================");

        // Check if the array is correctly sorted
        if (dut.d_mem.memory[0] == 1 &&
            dut.d_mem.memory[1] == 2 &&
            dut.d_mem.memory[2] == 3 &&
            dut.d_mem.memory[3] == 4) begin
            $display("SUCCESS: Array is perfectly sorted!");
        end else begin
            $display("ERROR: Array is NOT sorted correctly.");
        end
        $display("========================================\n");

        // End simulation
        $finish;
    end

endmodule
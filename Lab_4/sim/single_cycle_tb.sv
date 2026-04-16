`timescale 1ns / 1ps

module single_cycle_tb;
    logic clk;
    logic rst;

    // Instantiate the design Under Test (dut)
    single_cycle dut (
        .clk(clk),
        .rst(rst)
    );

    // Load machine code from a hex file (created during assembly)
    initial begin
        $readmemh("program.hex", dut.i_mem.rom);
    end

    // Clock generation (10ns period)
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    // Main simulation block
    initial begin
        // Setup waveform dumping
        $dumpfile("single_cycle_results.vcd");
        $dumpvars(0, single_cycle_tb);

        $display("-----------------------------------------------------");
        $display("                     TESTBENCH");
        $display("-----------------------------------------------------");

        // Apply reset
        rst = 1;
        #15;          
        rst = 0; // Start execution from PC = 0

        // Run long enough to execute the full test plan sequence
        #120; 

        $display("-----------------------------------------------------");
        $display("Simulation Complete. Output saved to single_cycle_results.vcd");
        $finish;
    end

    // Monitor block to track the PC and the specific registers from the test plan
    initial begin
        #20; // Wait for reset to clear
        $display("Time |    PC    | x0 | x1 | x2 | x3 (add) | x4 (sub) | x5 (and) | x6 (or) | x7 (addi -)");
        $display("---------------------------------------------------------------------------------------");
        forever begin
            @(posedge clk);
            // Print the state of the registers right after the clock edge
            $display("%4t | %h | %2d | %2d | %2d |    %2d    |    %2d    |    %2d    |    %2d   |      %2d", 
                     $time, 
                     dut.pc_out, 
                     dut.r_file.rf[0], 
                     dut.r_file.rf[1], 
                     dut.r_file.rf[2], 
                     dut.r_file.rf[3],
                     dut.r_file.rf[4],
                     dut.r_file.rf[5],
                     dut.r_file.rf[6],
                     dut.r_file.rf[7]);
        end
    end

    always @(posedge clk)
        
     begin
        #20;
        if (dut.r_file.rf[0] == 0 
        & dut.r_file.rf[1] == 15 
        & dut.r_file.rf[2] == 10
        & dut.r_file.rf[3] == 25
        & dut.r_file.rf[4] == 5
        & dut.r_file.rf[5] == 10
        & dut.r_file.rf[6] == 15
        & dut.r_file.rf[7] == 10)
        begin
            #10
            $display("ALL TESTCASES CORRECT");
            $finish;
            // $quit;
        end
    end

endmodule
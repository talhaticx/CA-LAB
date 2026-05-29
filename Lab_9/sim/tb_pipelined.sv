`timescale 1ns/1ps

module tb_pipelined;
    logic clk;
    logic rst;

    // Instantiate your 3-stage pipelined top module
    pipelined_3stage dut (
        .clk(clk),
        .rst(rst)
    );

    // Generate a clock signal (toggles every 10ns -> 20ns clock cycle)
    always #10 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        
        // Hold reset for 25ns
        #25;
        rst = 0; 
        
        // Let the simulation run for 300ns, then stop
        #300;
        $stop;
    end
endmodule
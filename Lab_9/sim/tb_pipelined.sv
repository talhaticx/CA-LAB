`timescale 1ns/1ns

module tb_pipelined();

    logic clk;
    logic rst;

    // Clock Generation (50MHz -> 20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Instantiate the 3-Stage Pipeline Processor
    three_stage_pipeline dut (
        .clk(clk),
        .rst(rst)
    );

    initial begin
        // Setup waveform dumping
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_pipelined);

        // ==========================================
        // 1. DRIVE RESET IMMEDIATELY AT TIME 0
        // Absolutely no `#` delays before this line!
        // ==========================================
        rst = 1;
        
        // 2. Hold reset for a couple of cycles, then release
        repeat(2) @(negedge clk); 
        rst = 0;

        // 3. Run the simulation for enough time to see results
        #270; 
        
        $finish;
    end

endmodule
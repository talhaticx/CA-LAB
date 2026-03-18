`timescale 1ns / 1ps

module single_cycle_tb;
    logic clk;
    logic rst;

    single_cycle uut (
        .clk(clk),
        .rst(rst)
    );

    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
       
        $dumpfile("single_cycle_results.vcd");
        $dumpvars(0, single_cycle_tb);

        $display("-----------------------------------------------------");
        $display("UET Lahore - EE-475L: RISC-V Single Cycle Simulation");
        $display("-----------------------------------------------------");


        rst = 1;
        #15;          
        rst = 0; // Start execution from PC = 0

        #100; 

        $display("Simulation Complete. Output saved to riscv_results.vcd");
        $finish;
    end

    // Monitor the Register File x3 to see the result (10 + 20 = 30)
    initial begin
        #20; 
        forever begin
            @(posedge clk);
            $display("Time: %0t | PC: %h | x3: %d", $time, uut.pc_out, uut.r_file.rf[3]);
        end
    end

endmodule
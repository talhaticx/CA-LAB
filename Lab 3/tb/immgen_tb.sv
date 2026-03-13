`timescale 1ns / 1ps
`include "opcode.vh"

module imm_gen_tb;
    logic [31:0] instruction;
    logic [31:0] immediate;
    logic [31:0] expected_imm;
    
    // Intermediate wire for opcode clarity
    logic [6:0] op;
    assign op = instruction[6:0];

    // Instantiate the Immediate Generator
    imm_gen uut (
        .instruction(instruction),
        .immediate(immediate)
    );

    initial begin
        $dumpfile("build/waves.vcd"); 
        $dumpvars(0, imm_gen_tb);

        $display("-----------------------------------------------------");
        $display("Starting Stable Randomized Testing for Lab 3");
        $display("-----------------------------------------------------");

        repeat (100) begin
            // 1. Generate random 32-bit instruction
            instruction = $urandom();
            
            // 2. Allow combinational logic to propagate
            #10;

            // 3. Golden Model Logic (Directly in-block to avoid vvp crash)
            case (op)
                `OPC_ARI_ITYPE, `OPC_LOAD, `OPC_JALR: 
                    expected_imm = {{20{instruction[31]}}, instruction[31:20]};
                
                `OPC_STORE: 
                    expected_imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                
                `OPC_BRANCH: 
                    expected_imm = {{19{instruction[31]}}, instruction[31], instruction[7], 
                                    instruction[30:25], instruction[11:8], 1'b0};
                
                `OPC_LUI, `OPC_AUIPC: 
                    expected_imm = {instruction[31:12], 12'b0};
                
                `OPC_JAL: 
                    expected_imm = {{11{instruction[31]}}, instruction[31], instruction[19:12], 
                                    instruction[20], instruction[30:21], 1'b0};
                
                default: expected_imm = 32'b0;
            endcase

            // 4. Comparison and validation
            // We only check if it's a valid RISC-V opcode from our header
            if (op == `OPC_ARI_ITYPE || op == `OPC_LOAD || op == `OPC_JALR || 
                op == `OPC_STORE || op == `OPC_BRANCH || op == `OPC_LUI || 
                op == `OPC_AUIPC || op == `OPC_JAL) begin
                
                if (immediate !== expected_imm) begin
                    $display("[FAIL] Op:%b | Instr:%h", op, instruction);
                    $display("       Expected: %h | Got: %h", expected_imm, immediate);
                end else begin
                    $display("[PASS] Op:%b | Imm: %h", op, immediate);
                end
            end
        end

        $display("-----------------------------------------------------");
        $display("Testing Complete.");
        $finish;
    end
endmodule
// =================================================================================
// Author: Maryam Hania
// Main Controller Module 
// =================================================================================

`include "opcode.vh"

module main_controller (
    input  logic [6:0] opcode,
    output logic [1:0] alu_op,
    output logic       reg_write,  // High for R, I, LW, JAL, LUI
    output logic       alu_src,    // 0 for Register, 1 for Immediate
    output logic [1:0] result_src, // 00: ALU, 01: Mem, 10: PC+4 (JAL), 11: Imm (LUI)
    output logic       mem_write,  // High for SW
    output logic       branch,     // High for Branches
    output logic       jump        // High for JAL
);

    always_comb begin
        // Default values to prevent latches
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        alu_op     = 2'b00;
        result_src = 2'b00;
        mem_write  = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;

        case (opcode)
            // R-Type
            `OPC_ARI_RTYPE: begin
                reg_write  = 1'b1;
                alu_src    = 1'b0; // Use RS2
                alu_op     = 2'b10;
                result_src = 2'b00; // ALU Result
            end

            // I-Type
            `OPC_ARI_ITYPE: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1; // Use Immediate
                alu_op     = 2'b11;
                result_src = 2'b00; // ALU Result
            end

            // Load Word (LW) 
            `OPC_LOAD: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1; // Use immediate for address offset
                alu_op     = 2'b00; // ALU does ADD
                result_src = 2'b01; // Route memory data to register
            end

            // Store Word (SW) - S-Type
            `OPC_STORE: begin
                reg_write  = 1'b0;
                alu_src    = 1'b1; // Use immediate for address offset
                alu_op     = 2'b00; // ALU does ADD
                mem_write  = 1'b1; // Enable memory writing
            end

            // Branches (BEQ, BNE) - B-Type
            `OPC_BRANCH: begin
                reg_write  = 1'b0;
                alu_src    = 1'b0; // Compare two registers
                alu_op     = 2'b01; // ALU does SUB for comparison
                branch     = 1'b1; // Signal PC to maybe jump
            end

            // Jump and Link (JAL) - J-Type
            `OPC_JAL: begin
                reg_write  = 1'b1; // Write return address to RD
                jump       = 1'b1; // Force PC jump
                result_src = 2'b10; // Route PC+4 to register
            end

            // Load Upper Immediate (LUI) - U-Type
            `OPC_LUI: begin
                reg_write  = 1'b1; // Write immediate to RD
                result_src = 2'b11; // Route immediate to register
            end

            default: ;
        endcase
    end
endmodule
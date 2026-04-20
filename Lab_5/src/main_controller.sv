// =================================================================================
// Author: Maryam Hania
// Main Controller Module 
// =================================================================================

`include "opcode.vh"

module main_controller (
    input  logic [6:0] opcode,
    output logic [1:0] alu_op,
    output logic       reg_write, // High for R and I type
    output logic       alu_src    // 0 for Register (R-type), 1 for Immediate (I-type)
    output logic       mem_to_reg, // NEW for LW
    output logic       mem_write,  // NEW for SW
    output logic       branch      // NEW for BEQ
);

    always_comb begin
        // Default values
        reg_write = 1'b0;
        alu_src   = 1'b0;
        alu_op    = 2'b00;
        mem_to_reg = 1'b0;
        mem_write  = 1'b0;
        branch     = 1'b0;

        case (opcode)
            `OPC_ARI_RTYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b0; // Use RS2
                alu_op    = 2'b10;
            end
            `OPC_ARI_ITYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1; // Use Immediate
                alu_op    = 2'b11;
            end
            // Load Word (LW) 
            `OPC_LOAD: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;   // Use immediate for address offset
                mem_to_reg = 1'b1;   // Route memory data to register
                alu_op     = 2'b00;  // ALU should do ADD
            end

            // Store Word (SW) 
            `OPC_STORE: begin
                reg_write  = 1'b0;   // Don't write to register
                alu_src    = 1'b1;   // Use immediate for address offset
                mem_write  = 1'b1;   // Enable memory writing
                alu_op     = 2'b00;  // ALU should do ADD
            end

            // Branch Equal (BEQ) 
            `OPC_BRANCH: begin
                reg_write  = 1'b0;
                alu_src    = 1'b0;   // Compare two registers
                branch     = 1'b1;   // Signal PC to maybe jump
                alu_op     = 2'b01;  // ALU should do SUB (for comparison)
            end
            // Note: Loads/Stores/Branches will be added later in Part 2 of Lab 4
            default: ;
        endcase
    end
endmodule
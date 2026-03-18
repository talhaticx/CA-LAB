`include "opcode.vh"

module main_controller (
    input  logic [6:0] opcode,
    output logic [1:0] alu_op,
    output logic       reg_write, // High for R and I type
    output logic       alu_src    // 0 for Register (R-type), 1 for Immediate (I-type)
);

    always_comb begin
        // Default values
        reg_write = 1'b0;
        alu_src   = 1'b0;
        alu_op    = 2'b00;

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
            // Note: Loads/Stores/Branches will be added later in Part 2 of Lab 4
            default: ;
        endcase
    end
endmodule
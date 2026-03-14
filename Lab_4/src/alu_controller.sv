// `include "opcode.vh"

module alu_controller (
    input  logic [1:0] alu_op,
    input  logic [2:0] func3,
    input  logic [6:0] func7,
    output logic [3:0] alu_operation
);

    always_comb begin
        case (alu_op)
            2'b00: alu_operation = 4'b0010; // Load/Store uses ADD
            2'b01: alu_operation = 4'b0110; // Branch uses SUB
            2'b10, 2'b11: begin // R-type and I-type
                case (func3)
                    `FNC_ADD_SUB: begin
                        if (alu_op == 2'b10 && func7 == `FNC7_1)
                            alu_operation = 4'b0110; // SUB
                        else
                            alu_operation = 4'b0010; // ADD
                    end
                    `FNC_SLL: alu_operation = 4'b0100;
                    `FNC_SLT: alu_operation = 4'b1000;
                    `FNC_SLTU: alu_operation = 4'b1001;
                    `FNC_XOR: alu_operation = 4'b0011;
                    `FNC_SRL_SRA: begin
                        if (func7 == `FNC7_1)
                            alu_operation = 4'b0111; // SRA
                        else
                            alu_operation = 4'b0101; // SRL
                    end
                    `FNC_OR:  alu_operation = 4'b0001;
                    `FNC_AND: alu_operation = 4'b0000;
                    default:  alu_operation = 4'b0000;
                endcase
            end
            default: alu_operation = 4'b0000;
        endcase
    end
endmodule

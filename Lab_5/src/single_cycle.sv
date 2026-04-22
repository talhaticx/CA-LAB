// =================================================================================
// Author: Maryam Hania
// Single Cycle Module 
// =================================================================================

module single_cycle (
    input logic clk,
    input logic rst
);
    // Internal Wires
    logic [31:0] pc_out, pc_next, pc_plus4, pc_branch, instr, imm_ext;
    logic [31:0] rd1, rd2, alu_result, operand_b, read_data, wd3_final;
    logic [3:0]  alu_ctrl_signal;
    logic [1:0]  alu_op_main, result_src;
    logic        reg_write_en, alu_src_sel, alu_zero;
    logic        mem_write, branch, jump, pc_src, take_branch;

    // 1. Program Counter
    pc pc_unit (
        .clk(clk), .rst(rst),
        .pc_next(pc_next), .pc_out(pc_out)
    );

    // 2. PC Logic & Branch Evaluation
    assign pc_plus4  = pc_out + 32'd4;
    assign pc_branch = pc_out + imm_ext; // Target address if branch or jump is taken
    
    // Evaluate branch condition (BEQ / BNE) based on func3
    always_comb begin
        case(instr[14:12])
            3'b000: take_branch = alu_zero;  // BEQ
            3'b001: take_branch = ~alu_zero; // BNE
            default: take_branch = 1'b0;
        endcase
    end

    // PC Source Mux: Jump unconditionally, OR branch if condition met
    assign pc_src  = jump | (branch & take_branch);
    assign pc_next = pc_src ? pc_branch : pc_plus4;

    // 3. Instruction Memory
    instr_mem i_mem (
        .addr(pc_out), .instr(instr)
    );

    // 4. Main Controller
    main_controller m_ctrl (
        .opcode(instr[6:0]),
        .alu_op(alu_op_main),
        .reg_write(reg_write_en),
        .alu_src(alu_src_sel),
        .result_src(result_src), // 2-bit wire
        .mem_write(mem_write),
        .branch(branch),
        .jump(jump)              // Added jump signal
    );

    // 5. Immediate Generator
    imm_gen imm_unit (
        .instruction(instr),
        .immediate(imm_ext)
    );

    // 6. Register File
    reg_file r_file (
        .clk(clk),
        .reg_write(reg_write_en),
        .a1(instr[19:15]), // rs1
        .a2(instr[24:20]), // rs2
        .a3(instr[11:7]),  // rd
        .wd3(wd3_final),   // Write back resolved data
        .rd1(rd1),
        .rd2(rd2)
    );

    // 7. Mux for ALU Operand B (Choose between Register rd2 or Immediate)
    assign operand_b = (alu_src_sel) ? imm_ext : rd2;

    // 8. ALU Controller
    alu_controller a_ctrl (
        .alu_op(alu_op_main),
        .func3(instr[14:12]),
        .func7(instr[31:25]),
        .alu_operation(alu_ctrl_signal)
    );

    // 9. ALU
    alu alu_unit (
        .operand_a(rd1),
        .operand_b(operand_b),
        .alu_operation(alu_ctrl_signal),
        .result(alu_result),
        .zero(alu_zero)
    );

    // 10. Data Memory
    data_mem d_mem (
        .clk(clk),
        .mem_write(mem_write),
        .addr(alu_result),
        .write_data(rd2),
        .read_data(read_data)
    );

    // 11. Write-Back Multiplexer (Result Source)
    always_comb begin
        case(result_src)
            2'b00: wd3_final = alu_result; // R-Type, I-Type
            2'b01: wd3_final = read_data;  // LW
            2'b10: wd3_final = pc_plus4;   // JAL
            2'b11: wd3_final = imm_ext;    // LUI
            default: wd3_final = 32'b0;
        endcase
    end

endmodule
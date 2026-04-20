// =================================================================================
// Author: Maryam Hania
// Single Cycle Module 
// =================================================================================

module single_cycle (
    input logic clk,
    input logic rst
);
    // Internal Wires
    logic [31:0] pc_out, pc_next, instr, imm_ext;
    logic [31:0] rd1, rd2, alu_result, operand_b;
    logic [3:0]  alu_ctrl_signal;
    logic [1:0]  alu_op_main;
    logic        reg_write_en, alu_src_sel, alu_zero;

    logic        mem_to_reg, mem_write, branch, pc_src;

    // 1. Program Counter
    pc pc_unit (
        .clk(clk), .rst(rst),
        .pc_next(pc_next), .pc_out(pc_out)
    );

    // 2. PC Logic 
    assign pc_plus4  = pc_out + 32'd4;
    assign pc_branch = pc_out + imm_ext; // Target address if branch is taken
    
    // PC Source Mux: Decide if we jump or go to next instruction
    assign pc_src = branch & alu_zero; 
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
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write),
        .branch(branch)
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
        .wd3(alu_result),  // Write back ALU result
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
    assign wd3_final = mem_to_reg ? read_data : alu_result;
endmodule
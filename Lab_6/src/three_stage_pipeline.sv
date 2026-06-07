// =================================================================================
// Author: Fatima Irfan Sohail
// 3-Stage Pipelined Processor Top Module
// Stages: 1. Fetch (F) | 2. Decode-Execute (DX) | 3. Memory-Writeback (MW)
// =================================================================================

module three_stage_pipeline (
    input logic clk,
    input logic rst
);

    // =============================================================================
    // 1. FETCH STAGE (F)
    // =============================================================================
    logic [31:0] pc_F, pc_next_F, pc_plus4_F, instr_F;
    logic pc_src_DX;       // Comes from DX stage branch logic
    logic [31:0] pc_branch_DX; // Comes from DX stage branch logic

    // Next PC selection (Branch/Jump resolved in DX stage)
    assign pc_next_F = pc_src_DX ? pc_branch_DX : pc_plus4_F;

    pc pc_unit (
        .clk(clk), .rst(rst),
        .pc_next(pc_next_F), .pc_out(pc_F)
    );

    assign pc_plus4_F = pc_F + 32'd4;

    instr_mem i_mem (
        .addr(pc_F), .instr(instr_F)
    );


    // =============================================================================
    // PIPELINE REGISTER 1: FETCH -> DECODE/EXECUTE (F_DX)
    // =============================================================================
    logic [31:0] instr_DX, pc_DX, pc_plus4_DX;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            instr_DX    <= 32'b0;
            pc_DX       <= 32'b0;
            pc_plus4_DX <= 32'b0;
        end else begin
            instr_DX    <= instr_F;
            pc_DX       <= pc_F;
            pc_plus4_DX <= pc_plus4_F;
        end
    end


    // =============================================================================
    // 2. DECODE-EXECUTE STAGE (DX)
    // =============================================================================
    logic [31:0] rd1_DX, rd2_DX, imm_ext_DX, alu_result_DX, operand_b_DX;
    logic [3:0]  alu_ctrl_signal_DX;
    logic [1:0]  alu_op_main_DX, result_src_DX;
    logic        reg_write_en_DX, alu_src_sel_DX, alu_zero_DX;
    logic        mem_write_DX, branch_DX, jump_DX, take_branch_DX;

    // These come from the MW stage to write back to the register file
    logic        reg_write_en_MW;
    logic [4:0]  rd_MW;
    logic [31:0] wd3_final_MW;

    main_controller m_ctrl (
        .opcode(instr_DX[6:0]),
        .alu_op(alu_op_main_DX),
        .reg_write(reg_write_en_DX),
        .alu_src(alu_src_sel_DX),
        .result_src(result_src_DX), 
        .mem_write(mem_write_DX),
        .branch(branch_DX),
        .jump(jump_DX)
    );

    imm_gen imm_unit (
        .instruction(instr_DX),
        .immediate(imm_ext_DX)
    );

    // Register File: Reads happen in DX, but Writes come from the MW stage!
    reg_file r_file (
        .clk(clk),
        .reg_write(reg_write_en_MW), // Control signal propagated from MW
        .a1(instr_DX[19:15]),        // rs1 (Decode)
        .a2(instr_DX[24:20]),        // rs2 (Decode)
        .a3(rd_MW),                  // rd (Propagated from MW)
        .wd3(wd3_final_MW),          // Write data (Propagated from MW)
        .rd1(rd1_DX),
        .rd2(rd2_DX)
    );

    assign operand_b_DX = (alu_src_sel_DX) ? imm_ext_DX : rd2_DX;

    alu_controller a_ctrl (
        .alu_op(alu_op_main_DX),
        .func3(instr_DX[14:12]),
        .func7(instr_DX[31:25]),
        .alu_operation(alu_ctrl_signal_DX)
    );

    alu alu_unit (
        .operand_a(rd1_DX),
        .operand_b(operand_b_DX),
        .alu_operation(alu_ctrl_signal_DX),
        .result(alu_result_DX),
        .zero(alu_zero_DX)
    );

    // PC Logic & Branch Evaluation in DX
    assign pc_branch_DX = pc_DX + imm_ext_DX; 
    
    always_comb begin
        case(instr_DX[14:12])
            3'b000: take_branch_DX = alu_zero_DX;  // BEQ
            3'b001: take_branch_DX = ~alu_zero_DX; // BNE
            default: take_branch_DX = 1'b0;
        endcase
    end
    assign pc_src_DX = jump_DX | (branch_DX & take_branch_DX);


    // =============================================================================
    // PIPELINE REGISTER 2: DECODE/EXECUTE -> MEMORY/WRITEBACK (DX_MW)
    // =============================================================================
    // Control signals to propagate
    logic       mem_write_MW;
    logic [1:0] result_src_MW;
    // Data to propagate
    logic [31:0] alu_result_MW, rd2_MW, pc_plus4_MW, imm_ext_MW;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_write_en_MW <= 1'b0;
            mem_write_MW    <= 1'b0;
            result_src_MW   <= 2'b00;
            alu_result_MW   <= 32'b0;
            rd2_MW          <= 32'b0;
            pc_plus4_MW     <= 32'b0;
            imm_ext_MW      <= 32'b0;
            rd_MW           <= 5'b0;
        end else begin
            // This ensures control signals propagate correctly through the pipeline
            reg_write_en_MW <= reg_write_en_DX;
            mem_write_MW    <= mem_write_DX;
            result_src_MW   <= result_src_DX;
            
            alu_result_MW   <= alu_result_DX;
            rd2_MW          <= rd2_DX; // Data to write to memory
            pc_plus4_MW     <= pc_plus4_DX;
            imm_ext_MW      <= imm_ext_DX;
            rd_MW           <= instr_DX[11:7]; // Destination register address
        end
    end


    // =============================================================================
    // 3. MEMORY-WRITEBACK STAGE (MW)
    // =============================================================================
    logic [31:0] read_data_MW;

    data_mem d_mem (
        .clk(clk),
        .mem_write(mem_write_MW),
        .addr(alu_result_MW),
        .write_data(rd2_MW),
        .read_data(read_data_MW)
    );

    // Write-Back Multiplexer
    always_comb begin
        case(result_src_MW)
            2'b00: wd3_final_MW = alu_result_MW; // R-Type, I-Type
            2'b01: wd3_final_MW = read_data_MW;  // LW
            2'b10: wd3_final_MW = pc_plus4_MW;   // JAL
            2'b11: wd3_final_MW = imm_ext_MW;    // LUI
            default: wd3_final_MW = 32'b0;
        endcase
    end

endmodule
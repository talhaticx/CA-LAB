// =================================================================================
// Hazard Detection and Forwarding Unit
// Resolves Read-After-Write (RAW) and Control Hazards for 3-Stage Pipeline
// =================================================================================

module hazard_unit (
    input  logic [4:0] rs1_DX,
    input  logic [4:0] rs2_DX,
    input  logic [4:0] rs1_F,
    input  logic [4:0] rs2_F,
    input  logic [4:0] rd_DX,
    input  logic [4:0] rd_MW,
    input  logic       reg_write_en_MW,
    input  logic [1:0] result_src_DX, // To detect Load instructions (2'b01)
    input  logic       pc_src_DX,     // High if branch is taken or jump

    output logic       forward_a_DX,
    output logic       forward_b_DX,
    output logic       stall_F,
    output logic       flush_DX
);
 
    // 1. Data Hazard Forwarding (MW -> DX)
    // If MW is writing to a register that DX needs right now, forward the data.
    // Register 0 (x0) is hardwired to 0 and should never be forwarded.
    assign forward_a_DX = (reg_write_en_MW && (rd_MW != 5'b0) && (rd_MW == rs1_DX));
    assign forward_b_DX = (reg_write_en_MW && (rd_MW != 5'b0) && (rd_MW == rs2_DX));

    // 2. Load-Use Data Hazard Detection
    // If an instruction in DX is a load, and the instruction in F needs that register, we MUST stall.
    logic lw_stall;
    assign lw_stall = (result_src_DX == 2'b01) && (rd_DX != 5'b0) && ((rd_DX == rs1_F) || (rd_DX == rs2_F));

    assign stall_F  = lw_stall;
    
    // 3. Control Hazard Flushing
    // We flush the instruction moving into DX if a Load-Use stalled it, OR if a branch was taken.
    assign flush_DX = lw_stall || pc_src_DX;

endmodule
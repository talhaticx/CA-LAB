`timescale 1ns/1ps
`include "../rtl/opcode.vh"

module controllers_tb;

    // inputs
    logic [6:0] opcode;
    logic [2:0] func3;
    logic [6:0] func7;
    
    // connection between controllers
    logic [1:0] alu_op;
    
    // final output
    logic [3:0] alu_operation;
    logic [3:0] expected_alu_op;

    // instantiate controllers
    main_controller main_ctrl (.opcode(opcode), .alu_op(alu_op));
    alu_controller alu_ctrl (.alu_op(alu_op), .func3(func3), .func7(func7), .alu_operation(alu_operation));

    // lists of only the supported stuff
    logic [6:0] valid_opcodes [5] = '{ `OPC_LOAD, `OPC_STORE, `OPC_BRANCH, `OPC_ARI_RTYPE, `OPC_ARI_ITYPE };
    logic [2:0] valid_func3 [8]   = '{ `FNC_ADD_SUB, `FNC_SLL, `FNC_SLT, `FNC_SLTU, `FNC_XOR, `FNC_SRL_SRA, `FNC_OR, `FNC_AND };
    logic [6:0] valid_func7 [2]   = '{ `FNC7_0, `FNC7_1 };

    initial begin
        $dumpfile("controllers.vcd");
        $dumpvars(0, controllers_tb);

        $display("==============================================");
        $display("starting constrained random testing...");
        $display("==============================================");

        for (int i = 0; i < 5000; i++) begin
            // pick a random index from the valid arrays
            opcode = valid_opcodes[$urandom_range(0, 4)];
            func3  = valid_func3[$urandom_range(0, 7)];
            func7  = valid_func7[$urandom_range(0, 1)];

            #1;

            if (opcode == `OPC_LOAD || opcode == `OPC_STORE) 
                expected_alu_op = 4'b0010;
            else if (opcode == `OPC_BRANCH) 
                expected_alu_op = 4'b0110;
            else if (opcode == `OPC_ARI_RTYPE || opcode == `OPC_ARI_ITYPE) begin
                case (func3)
                    `FNC_ADD_SUB: expected_alu_op = (opcode == `OPC_ARI_RTYPE && func7 == `FNC7_1) ? 4'b0110 : 4'b0010;
                    `FNC_SLL: expected_alu_op = 4'b0100;
                    `FNC_SLT: expected_alu_op = 4'b1000;
                    `FNC_SLTU: expected_alu_op = 4'b1001;
                    `FNC_XOR: expected_alu_op = 4'b0011;
                    `FNC_SRL_SRA: expected_alu_op = (func7 == `FNC7_1) ? 4'b0111 : 4'b0101;
                    `FNC_OR:  expected_alu_op = 4'b0001;
                    `FNC_AND: expected_alu_op = 4'b0000;
                    default:  expected_alu_op = 4'b0000;
                endcase
            end else begin
                expected_alu_op = 4'b0010;
            end

            if (i % 250 == 0) begin
                $display("test %0d | opcode: %b | func3: %b | func7: %b | expected: %b | got: %b", i, opcode, func3, func7, expected_alu_op, alu_operation);
            end

            if (alu_operation !== expected_alu_op) begin
                $display("----> FAIL at test %0d", i);
                $display("opcode: %b | func3: %b | func7: %b", opcode, func3, func7);
                $display("expected: %b | got: %b", expected_alu_op, alu_operation);
                $fatal;
            end
        end

        $display("==============================================");
        $display("all 5000 constrained random tests PASSED.");
        $display("==============================================");

        $finish;
    end

endmodule
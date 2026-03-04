`timescale 1ns/1ps

module alu_tb;

    // DUT signals
    logic [31:0] operand_a;
    logic [31:0] operand_b;
    logic [3:0]  alu_operation;

    logic [31:0] result;
    logic        zero;

    // Expected signals
    logic [31:0] expected_result;
    logic        expected_zero;
    string op_name;

    // Instantiate DUT
    alu dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_operation(alu_operation),
        .result(result),
        .zero(zero)
    );

    initial begin

        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);

        $display("==============================================");
        $display("Starting ALU Randomized Testing...");
        $display("==============================================");

        for (int i = 0; i < 10000; i++) begin

            operand_a     = $urandom();
            operand_b     = $urandom();
            alu_operation = $urandom_range(0, 9);

            #1;

            // Compute expected result
            unique case (alu_operation)

                4'b0000: expected_result = operand_a & operand_b;
                4'b0001: expected_result = operand_a | operand_b;
                4'b0010: expected_result = operand_a + operand_b;
                4'b0011: expected_result = operand_a ^ operand_b;
                4'b0100: expected_result = operand_a << operand_b[4:0];
                4'b0101: expected_result = operand_a >> operand_b[4:0];
                4'b0110: expected_result = operand_a - operand_b;
                4'b0111: expected_result = $signed(operand_a) >>> operand_b[4:0];
                4'b1000: expected_result =
                            ($signed(operand_a) < $signed(operand_b)) ? 32'd1 : 32'd0;
                4'b1001: expected_result =
                            (operand_a < operand_b) ? 32'd1 : 32'd0;
                default: expected_result = 32'd0;

            endcase

            expected_zero = (expected_result == 32'd0);

            // Print operation name
            case (alu_operation)
                4'b0000: op_name = "AND";
                4'b0001: op_name = "OR";
                4'b0010: op_name = "ADD";
                4'b0011: op_name = "XOR";
                4'b0100: op_name = "SLL";
                4'b0101: op_name = "SRL";
                4'b0110: op_name = "SUB";
                4'b0111: op_name = "SRA";
                4'b1000: op_name = "SLT";
                4'b1001: op_name = "SLTU";
                default: op_name = "UNKNOWN";
            endcase

            // Print test info
            if (i % 500 == 0) begin
                $display("Test %0d | OP: %s | A: %h | B: %h",
                    i, op_name, operand_a, operand_b);

                $display("Expected: %h | Got: %h | Zero Exp: %b | Zero Got: %b",
                        expected_result, result,
                        expected_zero, zero);
            end

            // Compare EVERY time, not just every 500th time
            if (result !== expected_result || zero !== expected_zero) begin
                $display("----> FAIL at test %0d | OP: %s", i, op_name);
                $display("A: %h | B: %h", operand_a, operand_b);
                $display("Expected: %h | Got: %h", expected_result, result);
                $fatal;
            end
            else if (i % 500 == 0) begin
                $display("----> PASS\n");
            end


        end

        $display("==============================================");
        $display("All 10000 random tests PASSED successfully.");
        $display("==============================================");

        $finish;

    end

endmodule
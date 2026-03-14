# ================================
# Lab 2 Makefile
# ================================

# Tools
VLOG = vlog
VSIM = vsim
GTKWAVE = gtkwave

# Directories
RTL_DIR = src
TB_DIR  = sim
BUILD_DIR = build

# Top modules
ALU_TB = alu_tb
CTRL_TB = controller_tb

# Files
ALU_FILES = $(RTL_DIR)/alu.sv $(TB_DIR)/alu_tb.sv
CTRL_FILES = $(RTL_DIR)/alu_controller.sv \
             $(RTL_DIR)/main_controller.sv \
             $(TB_DIR)/controller_tb.sv

# Default target
all: alu ctrl

# =================================
# ALU
# =================================
alu:
	@mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && \
	vlib work || true && \
	$(VLOG) ../rtl/alu.sv ../tb/alu_tb.sv && \
	$(VSIM) -c alu_tb -do "run -all; quit"

wave_alu:
	cd $(BUILD_DIR) && \
	$(GTKWAVE) alu.vcd

# =================================
# Controllers
# =================================
ctrl:
	@mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && \
	vlib work && \
	$(VLOG) ../rtl/main_controller.sv ../rtl/alu_controller.sv ../tb/controller_tb.sv && \
	$(VSIM) -c controllers_tb -do "run -all; quit"

wave_ctrl:
	cd $(BUILD_DIR) && \
	$(GTKWAVE) controllers.vcd

# =================================
# Clean
# =================================
clean:
	rm -rf $(BUILD_DIR)
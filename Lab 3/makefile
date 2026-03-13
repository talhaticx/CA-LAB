# ==========================================
# Lab 3 Makefile - Icarus Verilog (Stable)
# ==========================================

# Tools
IVERILOG = iverilog
VVP      = vvp
GTKWAVE  = gtkwave

# Directories
RTL_DIR   = rtl
TB_DIR    = tb
BUILD_DIR = build
INC_DIR   = ../include

# Files
RTL_FILES = $(RTL_DIR)/immgen.sv
TB_FILES  = $(TB_DIR)/immgen_tb.sv
SIM_EXE   = $(BUILD_DIR)/imm_sim

# Default target
all: imm

# ==========================================
# Compile and Run
# ==========================================
imm:
	@mkdir -p $(BUILD_DIR)
	$(IVERILOG) -I $(INC_DIR) -g2012 -o $(SIM_EXE) $(RTL_FILES) $(TB_FILES)
	$(VVP) $(SIM_EXE)

# ==========================================
# View Waveforms
# ==========================================
imm_wave:
	$(GTKWAVE) $(BUILD_DIR)/waves.vcd

# ==========================================
# Clean
# ==========================================
clean:
	rm -rf $(BUILD_DIR)
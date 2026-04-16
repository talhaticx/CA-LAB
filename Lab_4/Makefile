# ================================
# Lab 4 Makefile
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
TOP_TB = single_cycle_tb

# Files (Referenced from inside the build directory)
RTL_FILES = ../$(RTL_DIR)/*.sv

TB_FILES  = ../$(TB_DIR)/single_cycle_tb.sv

# Default target
all: run

# =================================
# Single Cycle Processor
# =================================
run:
	@mkdir -p $(BUILD_DIR)
	@cp program.hex $(BUILD_DIR)/ || true
	cd $(BUILD_DIR) && \
	vlib work || true && \
	$(VLOG) +incdir+../$(RTL_DIR) $(RTL_FILES) $(TB_FILES) && \
	$(VSIM) -c $(TOP_TB) -do "run -all; quit"

wave:
	cd $(BUILD_DIR) && \
	$(GTKWAVE) single_cycle_results.vcd

# =================================
# Clean
# =================================
clean:
	rm -rf $(BUILD_DIR)
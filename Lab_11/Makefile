# ==========================================
# Makefile for RISC-V Pipelined Processor
# ==========================================

# Directories
SRC_DIR = src
SIM_DIR = sim

# RISC-V Compiler Settings
GCC = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
CFLAGS = -march=rv32i -mabi=ilp32 -nostdlib -Ttext 0x00000000

# Software Files
ASM_SRC = $(SIM_DIR)/insertion_sort.s
ELF_BIN = $(SIM_DIR)/insertion_sort.elf
HEX_OUT = $(SIM_DIR)/insertion_sort.hex

# QuestaSim Settings
VLOG = vlog
VSIM = vsim
WORK_DIR = work
TOP_TB = testbench # Replace with your actual testbench module name if different

# Default target
all: help

# 1. Compile Assembly to Hex
hex: $(ASM_SRC)
	@echo "Compiling RISC-V Assembly..."
	$(GCC) $(CFLAGS) -o $(ELF_BIN) $(ASM_SRC)
	$(OBJCOPY) -O verilog $(ELF_BIN) $(HEX_OUT)
	@echo "Hex file successfully generated: $(HEX_OUT)"

# 2. Compile SystemVerilog RTL and Testbench
compile:
	@echo "Creating work library and compiling SystemVerilog files..."
	vlib $(WORK_DIR)
	vmap work $(WORK_DIR)
	$(VLOG) +incdir+$(SRC_DIR)/include $(SRC_DIR)/*.sv $(SIM_DIR)/*.sv

# 3. Run Simulation (GUI Mode)
sim: hex compile
	@echo "Starting QuestaSim GUI..."
	$(VSIM) -voptargs=+acc work.$(TOP_TB) -do "add wave -r /*; run -all"

# 4. Clean up generated files
clean:
	@echo "Cleaning up build and simulation files..."
	rm -rf $(WORK_DIR) transcript vsim.wlf modelsim.ini
	rm -f $(ELF_BIN) $(HEX_OUT)

# Help menu
help:
	@echo "Available commands:"
	@echo "  make hex     - Compiles the RISC-V assembly into a .hex file"
	@echo "  make compile - Compiles all .sv files in src/ and sim/ using QuestaSim"
	@echo "  make sim     - Generates hex, compiles RTL, and opens QuestaSim GUI"
	@echo "  make clean   - Removes all generated files and libraries"
# =================================================================================
# RISC-V Pipelined Processor Makefile
# =================================================================================

# Tools
VLOG = vlog
VSIM = vsim
GTKWAVE = gtkwave

# SW Toolchain
PREFIX  = riscv64-unknown-elf-
AS      = $(PREFIX)gcc
OBJCOPY = $(PREFIX)objcopy
AS_FLAGS = -nostdlib -nodefaultlibs -Ttext 0x00000000 -Wl,-e,0

# Directories
RTL_DIR   = src
TB_DIR    = sim
BUILD_DIR = build

# Top module inside the testbench
TOP_TB = testbench

# Files
RTL_FILES = ../$(RTL_DIR)/*.sv
TB_FILES  = ../$(TB_DIR)/testbench.sv

# Default target
all: run

# =================================================================================
# Software Assembly Compilation Rules (Sequential Byte Stream Format)
# =================================================================================

with_hazard:
	@mkdir -p $(BUILD_DIR)
	$(AS) $(AS_FLAGS) -o $(BUILD_DIR)/program.elf $(TB_DIR)/with_hazard.s
	$(OBJCOPY) -O binary $(BUILD_DIR)/program.elf $(BUILD_DIR)/program.bin
	# Formats raw binary into 16 uppercase space-separated byte hex blocks per line
	hexdump -v -e '16/1 "%02X " "\n"' $(BUILD_DIR)/program.bin > $(TB_DIR)/program.hex
	@echo "Successfully compiled with_hazard.s -> sim/program.hex"

without_hazard:
	@mkdir -p $(BUILD_DIR)
	$(AS) $(AS_FLAGS) -o $(BUILD_DIR)/program.elf $(TB_DIR)/without_hazard.s
	$(OBJCOPY) -O binary $(BUILD_DIR)/program.elf $(BUILD_DIR)/program.bin
	# Formats raw binary into 16 uppercase space-separated byte hex blocks per line
	hexdump -v -e '16/1 "%02X " "\n"' $(BUILD_DIR)/program.bin > $(TB_DIR)/program.hex
	@echo "Successfully compiled without_hazard.s -> sim/program.hex"

# =================================================================================
# Run Simulation
# =================================================================================
run:
	@mkdir -p $(BUILD_DIR)
	cp $(TB_DIR)/program.hex $(BUILD_DIR)/ 2>/dev/null || true
	cd $(BUILD_DIR) && \
	vlib work && \
	$(VLOG) +incdir+../$(RTL_DIR) $(RTL_FILES) $(TB_FILES) && \
	$(VSIM) -c $(TOP_TB) -do "run -all; quit"

# =================================================================================
# View Waveforms
# =================================================================================
wave:
	cd $(BUILD_DIR) && \
	$(GTKWAVE) dump.vcd wave.gtkw

# =================================================================================
# Clean Build Directory
# =================================================================================
clean:
	rm -rf $(BUILD_DIR)
	rm -f $(TB_DIR)/program.hex

.PHONY: all run wave clean with_hazard without_hazard
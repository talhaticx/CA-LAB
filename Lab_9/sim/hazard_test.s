# BASELINE TEST (No hazards)
addi x1, x0, 10      # x1 = 10
addi x2, x0, 20      # x2 = 20
nop                  # Give it time to pass through pipeline
nop

# 1. DATA HAZARD TEST (Read-After-Write)
# The sub instruction needs x3 right after add calculates it.
add x3, x1, x2       # x3 = 30 (Calculated in DX, writes in MW)
sub x4, x3, x1       # Tries to read x3 in DX before MW writes it!

# 2. CONTROL HAZARD TEST (Branching)
beq x1, x1, jump_target  # Branch is definitely taken (10 == 10)
addi x5, x0, 99      # This is fetched by mistake and should NOT execute!
nop

jump_target:
addi x6, x0, 50      # Execution should jump straight here

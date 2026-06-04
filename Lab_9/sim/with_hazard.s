addi x1, x0, 6
addi x2, x0, 2
add  x4, x1, x2
sw   x4, 0x20(x0)
lw   x9, 0x20(x0)
add  x5, x9, x2
add  x11, x1, x2
beq  x4, x11, label
addi x9, x0, 2
addi x4, x0, 16
label: or x2, x9, x4
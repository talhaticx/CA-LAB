# sim/insertion_sort.s
.text
.globl _start

_start:
    # Initialize parameters
    addi x10, x0, 0          # x10 = base address of arr (0)
    addi x11, x0, 4          # x11 = n = 4
    addi x12, x0, 1          # x12 = i = 1

outer_loop:
    bge x12, x11, end_sort   # if (i >= n), exit loop

    # int key = arr[i];
    slli x13, x12, 2         # x13 = i * 4 (byte offset)
    add  x14, x10, x13       # x14 = arr + i*4 (address of arr[i])
    lw   x15, 0(x14)         # x15 = key = arr[i]

    # int j = i - 1;
    addi x16, x12, -1        # x16 = j = i - 1

inner_loop:
    blt  x16, x0, insert_key # if (j < 0), break inner loop

    # Fetch arr[j]
    slli x17, x16, 2         # x17 = j * 4
    add  x18, x10, x17       # x18 = arr + j*4 (address of arr[j])
    lw   x19, 0(x18)         # x19 = arr[j]

    # arr[j] > key ?
    ble  x19, x15, insert_key # if (arr[j] <= key), break inner loop

    # arr[j + 1] = arr[j];
    sw   x19, 4(x18)         # Store arr[j] into arr[j+1] (which is offset by 4 bytes)

    # j--;
    addi x16, x16, -1        # j = j - 1
    jal  x0, inner_loop      # Loop back

insert_key:
    # arr[j + 1] = key;
    addi x17, x16, 1         # temp = j + 1
    slli x17, x17, 2         # (j + 1) * 4
    add  x18, x10, x17       # address of arr[j+1]
    sw   x15, 0(x18)         # Store key

    # i++;
    addi x12, x12, 1         # i = i + 1
    jal  x0, outer_loop      # Loop back

end_sort:
    jal  x0, end_sort        # Infinite loop to halt execution
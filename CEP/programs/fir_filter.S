# fir_filter.S
# a0 = pointer to samples array
# a1 = pointer to coefficients array
# a2 = pointer to output
# a3 = number of taps
# a4 = clip_flag (0 = ok, nonzero = overflow detected)

.text
.globl fir_filter
.type fir_filter, @function

fir_filter:
    li      t0, 0           # accumulator = 0
    li      t1, 0           # loop index i = 0

loop:
    bge     t1, a3, done    # if i >= taps, exit

    lw      t2, 0(a0)       # load sample[i]
    lw      t3, 0(a1)       # load coeff[i]

    imac    t0, t2, t3, t0  # t0 = t2 * t3 + t0  (fused multiply-accumulate)

    addi    a0, a0, 4       # next sample
    addi    a1, a1, 4       # next coeff
    addi    t1, t1, 1       # i++
    j       loop

done:
    cabs    t0, t0          # magnitude of filtered output
    bitrev  t0, t0          # bit-reverse for downstream FFT index mapping
    swc     t0, (a2), a4    # store ONLY if clip_flag == 0

    ret
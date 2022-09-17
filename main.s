
    .arch armv8-a

    .data
    .align 2

PI2:
    .float 1.57079632679489

arg_error:
    .asciz "No first argument\n"

file_error:
    .asciz "Error opening file\n"

prescision_error:
    .asciz "Incorrect prescision\n"

x_too_big_error:
    .asciz "x is too big\n"

fopen_w_mode:
    .asciz "w"

s_x:
    .asciz "x: "
s_prescision:
    .asciz "prescision: "

scan_float:
    .asciz "%f"
scan_int:
    .asciz "%d"

s_arccos:
    .asciz "arccos x = %.17lf\n"

s_series:
    .asciz "series = %.7f\n"

s_index_value:
    .asciz "%d: %.7f\n"

    .text
    .align 2

    .global main
    .type main, %function
main:
    stp x29, x30, [sp, -32]!
    mov x29, sp
    // x0 = argc
    // x1 = argv

    cmp x0, #1
    bne 1f
        // no first argument
        adr x0, arg_error
        bl printf
        b exit
    1:

    add x1, x1, #8 // skip 1st arg
    ldr x2, [x1]   // char* filename

    mov x0, x2
    adr x1, fopen_w_mode
    bl fopen

    mov x28, x0
    cmp x0, xzr
    bne 1f
        adr x0, file_error
        bl printf
        b exit
    1:

    adr x0, s_x
    bl printf
    adr x0, scan_float
    add x1, x29, 24
    bl scanf

    // s8 = x
    ldr s8, [x29, 24]

    adr x0, s_prescision
    bl printf
    adr x0, scan_int
    add x1, x29, 24
    bl scanf

    // x21 = prescision
    ldr x19, [x29, 24]

    fmov s0, s8
    fabs s1, s0
    fmov s2, 1
    fcmp s1, s2
    ble 1f
        adr x0, x_too_big_error
        bl printf
        b exit
    1:

    cmp x21, xzr
    blt 1f
    cmp x21, 17
    bgt 1f
    b 2f
    1:
        adr x0, prescision_error
        bl printf
        b exit
    2:

    fcvt d0, s8
    bl acos

    adr x0, s_arccos
    // d0 = arccos(x)
    bl printf

    mov x0, x19
    fmov s1, 1
    fmov s10, 10
    prescision_loop:
        fdiv s1, s1, s10
        sub x0, x0, #1
        cbnz x0, prescision_loop

    fmov s15, s1 // prescision

    interesting:
    mov x20, 0 // n
    mov x21, 1 // 2n + 1
    fmov s9, s8 // s9 = x^(2n + 1)
    fmul s8, s8, s8 // x^2
    fmov s10, wzr // sum

    loop:
        scvtf s0, x21
        fdiv s0, s9, s0   // /= 2n + 1

        fadd s10, s10, s0

        fmov s14, s0

        mov x0, x28
        adr x1, s_index_value
        mov x2, x20
        fcvt d0, s0
        bl fprintf

        fabs s0, s10
        fmov s1, 1
        fmov s2, 10
        1:
            fcmp s0, s1
            bge 2f
            fmul s0, s0, s2
            b 1b
        2:
        fdiv s1, s10, s0

        fdiv s0, s14, s1
        fabs s0, s0
        fcmp s0, s15 // < prescision
        blt calculated

        add x20, x20, 1
        add x21, x21, 2

        fmul s9, s9, s8  // *= x^2
        
        scvtf s0, x20    // n
        fmul s0, s0, s0  // n^2
        fdiv s9, s9, s0  // /= n^2

        add x0, x20, x20
        scvtf s0, x0
        fmul s9, s9, s0  // *= 2n
        
        sub x0, x0, 1
        scvtf s0, x0
        fmul s9, s9, s0  // *= 2n-1
        
        fmov s0, 4
        fdiv s9, s9, s0

        b loop
    calculated:

    adr x0, PI2
    ldr s3, [x0]
    fsub s10, s3, s10 // pi/2 - arcsin x

    adr x0, s_series
    fcvt d0, s10
    bl printf

    mov x0, x28
    bl fclose
exit:
    mov     sp, x29
    ldp     x29, x30, [sp], 32
    ret

    .size   main, (. - main)

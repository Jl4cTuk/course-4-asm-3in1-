section .data
    table_title db "x y", 10, 0
    format db "%.2f %.6f", 10, 0
    start_x dd 0.0
    end_x dd 1.0
    step dd 0.2

section .bss
    x_value resd 1
    y_value resd 1

section .text
    global _start
    extern printf, cbrt, atan, exp, cos

_start:
    push ebp
    mov ebp, esp

    fld dword [start_x]
    fstp dword [x_value]

    push dword table_title
    call printf
    add esp, 4

.loop:
    fld dword [x_value]

    sub esp, 4
    fst dword [esp]
    call cbrt
    add esp, 4
    ; st0: cbrt(x)

    fld st0

    sub esp, 4
    fld dword [x_value]
    fst dword [esp]
    call atan
    add esp, 4
    ; st0: atan(x)

    fadd st1, st0
    fstp st0

    fld1
    fadd st1, st0
    fstp st0
    ; denominator в st1

    ; exp(-x) + cos(x)
    fld dword [x_value]
    fchs
    sub esp, 4
    fst dword [esp]
    call exp
    add esp, 4
    ; st0: exp(-x)

    fld dword [x_value]
    call cos
    ; st0: cos(x), st1: exp(-x)

    faddp st1, st0

    fdiv st1
    fstp dword [y_value]

    push dword [y_value]
    push dword [x_value]
    push dword format
    call printf
    add esp, 12

    fld dword [x_value]
    fadd dword [step]
    fstp dword [x_value]

    fld dword [end_x]
    fld dword [x_value]
    fcom st1
    fstsw ax
    sahf

    jbe .loop

    mov eax, 0
    leave
    ret

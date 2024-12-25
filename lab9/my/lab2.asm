section .data
    prompt_a      db "a: ", 0
    prompt_x0     db "x0: ", 0
    prompt_eps    db "EPS: ", 0
    fmt_double    db "%lf", 0
    fmt_calc      db "Рассчитанное значение: %.10f", 10, 0
    fmt_std       db "Стандартное значение: %.10f", 10, 0
    fmt_iters     db "Количество итераций: %d", 10, 0

section .bss
    a resq 1
    x0 resq 1
    eps resq 1
    iterations resd 1
    calc_val resq 1
    std_val resq 1

section .text
    global main
    extern printf, scanf, log, pow

main:

    push prompt_a
    call printf
    add esp, 4

    push a
    push fmt_double
    call scanf
    add esp, 8

    push prompt_x0
    call printf
    add esp, 4

    push x0
    push fmt_double
    call scanf
    add esp, 8

    push prompt_eps
    call printf
    add esp, 4

    push eps
    push fmt_double
    call scanf
    add esp, 8

    push dword iterations
    push x0
    push a
    push eps
    call calculate_power
    add esp, 16
    fstp qword [calc_val]

    fld qword [a]
    fld qword [x0]
    call pow
    fstp qword [std_val]

    push dword [calc_val + 4]    ; Старшая часть double
    push dword [calc_val]        ; Младшая часть double
    push fmt_calc
    call printf
    add esp, 12

    push dword [std_val + 4]
    push dword [std_val]
    push fmt_std
    call printf
    add esp, 12

    push [iterations]
    push fmt_iters
    call printf
    add esp, 8

    push 0
    call exit

calculate_power:
    ; a - [esp + 4]
    ; x - [esp + 8]
    ; eps - [esp + 12]
    ; iterations - [esp + 16]

    fld1
    fstp qword [term]

    fld1
    fstp qword [result]

    fld qword [a]
    call log
    fstp qword [ln_a]

    mov dword [n], 1
    mov dword [iterations], 0

.loop_calc:
    ; fabs(term) > eps
    fld qword [term]
    fabs
    fld qword [eps]
    fcomi st0, st1
    fstsw ax
    sahf
    jae .continue_calc
    jmp .end_calc

.continue_calc:
    ; term *= (ln_a * x) / n
    fld qword [ln_a]
    fld qword [x0]
    fmulp st1, st0
    fild dword [n]
    fdiv st1, st0
    fld qword [term]
    fmul st1, st0
    fstp qword [term]

    ; result += term
    fld qword [result]
    fld qword [term]
    faddp st1, st0
    fstp qword [result]

    inc dword [n]

    mov eax, [iterations]
    inc dword [eax]

    jmp .loop_calc

.end_calc:
    fld qword [result]
    ret

section .bss
    term resq 1
    result resq 1
    ln_a resq 1
    n resd 1


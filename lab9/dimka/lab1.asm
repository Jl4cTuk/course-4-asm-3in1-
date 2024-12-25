section .data
    ; Форматные строки
    fmt_header db "x y",10,0
    fmt_output db "%.2f %.6f",10,0

    ; Константы
    start_val dd 4.0
    end_val   dd 5.0
    step_val  dd 0.1

section .bss
    x_value resd 1
    y_value resd 1
    temp resd 1

section .text
    global main
    extern printf
    extern cbrtf

;----------------------------------------------------------------------------------
; Функция calculate_y(x):
; y = (x - 1) / (x*x - 5*x + 6) + cbrt(2*x + 1)
; Вход: аргумент x в стеке (по cdecl, x лежит по адресу [esp+4])
; Выход: результат в ST(0)
;----------------------------------------------------------------------------------
calculate_y:
    ; Сохранение базового адреса стека
    push ebp
    mov ebp, esp

    ; Загрузка x в FPU
    fld dword [ebp+8]      ; ST(0) = x

    ; Вычисляем (x*x - 5*x + 6)
    fld st0                ; ST(0)=x, ST(1)=x
    fmul st0, st1          ; ST(0)=x*x, ST(1)=x
    ; x*x в ST(0)
    fld st1                ; ST(0)=x, ST(1)=x*x, ST(2)=x
    fmul dword [five]      ; ST(0)=5*x, ST(1)=x*x, ST(2)=x
    fsub st1, st0          ; (x*x) - (5*x), ST(0)=5*x, ST(1)=x*x - 5*x, ST(2)=x
    ; теперь ST(1) = x*x - 5*x
    ffree st0              ; освободим ST(0)
    fstp st0               ; уберём 5*x из стека, осталось ST(0)=x*x - 5*x, ST(1)=x

    ; Добавляем 6: (x*x - 5*x + 6)
    fadd dword [six]       ; ST(0) = x*x - 5*x + 6
    ; это наш знаменатель

    ; Числитель (x-1)
    fld dword [ebp+8]      ; ST(0)=x, ST(1)=denominator, ST(2)=x
    fsub dword [one]       ; ST(0)=x-1, ST(1)=denominator, ST(2)=x

    ; Делим (x-1)/denominator
    fdiv st0, st1          ; ST(0) = (x-1)/(x*x - 5*x + 6), ST(1)=denominator, ST(2)=x

    ; Уберём denominator из стека
    fstp st1               ; ST(0)=(x-1)/denominator, ST(1)=x

    ; Теперь добавим cbrt(2*x+1)
    ; Для cbrt вызовем cbrtf(2*x+1):
    fld st1                ; ST(0)=x, ST(1)=(x-1)/denominator, ST(2)=x
    fmul dword [two]       ; ST(0)=2*x, ST(1)=(x-1)/denominator, ST(2)=x
    fadd dword [one]       ; ST(0)=2*x+1, ST(1)=(x-1)/denominator, ST(2)=x

    ; Сохраним 2*x+1 в temp для вызова cbrtf
    fst dword [temp]
    fstp st0               ; убираем 2*x+1 из стека

    ; Вызов cbrtf(2*x+1)
    ; cbrtf прототип: float cbrtf(float)
    push dword [temp]      ; аргумент на стек
    call cbrtf
    add esp, 4
    ; результат cbrtf в ST(0)

    ; Теперь ST(0)=cbrtf(2*x+1), ST(1)=(x-1)/denominator, ST(2)=x
    fadd st1, st0          ; (x-1)/denominator + cbrtf(2*x+1)
    fstp st0               ; убираем cbrt(...) оставив сумму в ST(0)
    fstp st0               ; убираем x

    ; Теперь ST(0)=y

    ; Возврат
    mov esp, ebp
    pop ebp
    ret

; Константы для вычислений
section .data
five: dd 5.0
six: dd 6.0
one: dd 1.0
two: dd 2.0

section .text
main:
    push ebp
    mov ebp, esp
    sub esp, 16 ; немного места под локальные переменные, если нужно

    ; printf("x y\n");
    push dword fmt_header
    call printf
    add esp, 4

    ; x = start_val
    fld dword [start_val]
    fst dword [x_value]

.loop:
    ; Проверка условия: x <= end + step/2?
    ; Загрузим x и (end_val + half_step)
    fld dword [x_value]      ; ST(0)=x
    fld dword [end_val]      ; ST(0)=end, ST(1)=x
    fcompp
    fstsw ax
    sahf
    ja .done  ; если x > end+step/2, выходим из цикла

    ; Вызываем calculate_y(x)
    ; аргумент x лежит в памяти [x_value]
    push dword [x_value]
    call calculate_y
    add esp,4
    ; возвращённое значение в ST(0)
    fst dword [y_value]      ; сохраним y в памяти
    fstp st0

    ; printf("%.2f %.6f\n", x, y);
    push dword [y_value]
    push dword [x_value]
    push dword fmt_output
    call printf
    add esp, 12

    ; x = x + step
    fld dword [x_value]
    fadd dword [step_val]
    fst dword [x_value]
    fstp st0

    jmp .loop

.done:
    ; Возврат из main
    mov esp, ebp
    pop ebp
    xor eax, eax
    ret

section .data
    format_double_input db "%lf",0
    format_double_output db "%.10f",0
    format_int_output db "%d",0
    prompt_x0 db "x0: ",0
    prompt_eps db "EPS: ",0
    msg_calc_value db "Рассчитанное значение: ",0
    msg_std_value db "Стандартное значение: ",0
    msg_iterations db "Количество итераций: ",0
    newline db 10,0

section .bss
    x0 resq 1
    eps resq 1
    term resq 1
    result resq 1
    sign resq 1
    n resd 1
    iterations resd 1
    temp_value resq 1
    term_abs resq 1
    x_sqr resq 1

section .text
    global main
    extern printf, scanf, cos, fabs

;-------------------------------------
; double calculate_cos(double x, double eps, int *iterations)
; Логика:
; term = 1.0
; result = 1.0
; sign = -1.0
; n = 2
; iterations = 0
; while (fabs(term) > eps) {
;   term *= (x*x)/(n*(n-1))
;   result += sign * term
;   sign = -sign
;   n += 2
;   iterations++
; }
; return result;
;-------------------------------------

; Мы будем реализовывать цикл в main, т.к. отдельно функцию делать не требуется.
; Но для удобства - последовательная логика.

main:
    ; Ввод x0
    push prompt_x0
    call printf
    add esp,4

    push x0         ; &x0
    push format_double_input
    call scanf
    add esp,8

    ; Ввод eps
    push prompt_eps
    call printf
    add esp,4

    push eps
    push format_double_input
    call scanf
    add esp,8

    ; Инициализация:
    ; term = 1.0
    ; result = 1.0
    ; sign = -1.0
    ; n = 2
    ; iterations = 0

    fld1
    fst qword [term]

    fld1
    fst qword [result]

    fld1
    fchs              ; теперь в ST(0) -1.0
    fst qword [sign]

    mov dword [n], 2
    mov dword [iterations], 0

    ; Вычислим x*x и сохраним для удобства
    fld qword [x0]
    fld qword [x0]
    fmulp st1, st0    ; st0 = x0*x0
    fst qword [x_sqr]

calc_loop:
    ; Проверка условия цикла: while (fabs(term) > eps)
    ; fabs(term):
    ; Вызов fabs(term):
    fld qword [term]     ; ST(0) = term
    fst qword [temp_value]
    ; Передача аргумента для fabs на стек (double):
    ; push в порядке младших байт:
    push dword [temp_value]        ; lower 4 bytes
    push dword [temp_value+4]      ; higher 4 bytes
    call fabs
    add esp,8
    fst qword [term_abs]

    ; Сравнить term_abs и eps
    fld qword [term_abs]
    fld qword [eps]
    fcomip st0, st1
    fstp st0  ; освободим стек
    jae end_loop   ; если term_abs <= eps, выходим (jae с fcomip означает если st0>=st1 прыгаем; но мы использовали обратный порядок!)
    ; Внимание: Использовали fcomip st0, st1:
    ; fcomip st0, st1: если st0 > st1 => CF=0, ZF=0, je=..., ja - проверить документацию:
    ; Чтобы не путаться, сделаем обратную логику:
    ; Нам надо проверить: fabs(term) > eps. Если fabs(term)<=eps, выходим.
    ; После fcomip: ZF=1 если равны, CF=1 если st0<st1
    ; Нам надо: if fabs(term) <= eps => goto end_loop
    ; fabs(term) <= eps означает st0 <= st1, тогда после fcomip st0, st1
    ; при st0<=st1 будет CF=1 или ZF=1 => JBE (jump if below or equal) или JNA
    ; Используем jbe end_loop для <=
    jbe end_loop

    ; Цикл продолжается, вычисляем следующий term:
    ; term = term * (x*x)/(n*(n-1))
    ; Загрузим term:
    fld qword [term]
    fld qword [x_sqr]
    fmulp st1, st0  ; st0 = term*x^2

    ; загрузим n*(n-1)
    mov eax, [n]
    mov ebx, eax
    dec ebx         ; n-1
    ; (n*(n-1)) в ebx*eax
    imul ebx, eax
    ; теперь ebx = n*(n-1)
    ; превратим в double:
    ; поместим ebx в st0 как int->double:
    push ebx
    fild dword [esp] ; st0 = double(n*(n-1))
    add esp,4

    fdivp st1, st0  ; st1 = (term*x^2)/(n*(n-1)), st0 освобождается
    fst qword [term]

    ; result += sign * term
    fld qword [result]
    fld qword [sign]
    fld qword [term]
    fmulp st1, st0  ; st1 = sign*term
    faddp st1, st0  ; st1 = result + (sign*term)
    fst qword [result]

    ; sign = -sign
    fld qword [sign]
    fchs
    fst qword [sign]

    ; n += 2
    mov eax, [n]
    add eax, 2
    mov [n], eax

    ; iterations++
    mov eax, [iterations]
    add eax, 1
    mov [iterations], eax

    jmp calc_loop

end_loop:

    ; Результат вычисления в result

    ; Вычислим стандартное значение cos(x0)
    ; push аргумент (x0) для cos:
    ; cos(double) - передача double на стек:
    ; double x0 в [x0]
    push dword [x0]        ; младшие 4 байта
    push dword [x0+4]      ; старшие 4 байта
    call cos
    add esp, 8
    fst qword [temp_value] ; сохраним стандартное значение

    ; Печать результатов:
    ; "Рассчитанное значение: %.10f\n"
    push msg_calc_value
    call printf
    add esp,4

    push dword [result]      ; low part of result
    push dword [result+4]    ; high part of result
    push format_double_output
    call printf
    add esp,12

    push newline
    call printf
    add esp,4

    ; "Стандартное значение: %.10f\n"
    push msg_std_value
    call printf
    add esp,4

    push dword [temp_value]
    push dword [temp_value+4]
    push format_double_output
    call printf
    add esp,12

    push newline
    call printf
    add esp,4

    ; "Количество итераций: %d\n"
    push msg_iterations
    call printf
    add esp,4

    push dword [iterations]
    push format_int_output
    call printf
    add esp,8

    push newline
    call printf
    add esp,4

    ; Завершение
    xor eax, eax
    ret

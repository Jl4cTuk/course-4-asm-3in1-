section .data
    table_title db "x y", 10, 0    ; Заголовок таблицы
    format db "%.2lf %.6lf", 10, 0          ; Формат вывода x и y
    h dq 0.05                                ; Шаг h
    start_x dq 0.1                           ; Начальное значение x
    end_x dq 1.1                             ; Конечное значение x

section .bss
    result resq 1                            ; Для хранения результата y
    x_value resq 1                           ; Текущее значение x
    one resq 1                               ; Для хранения числа 1

section .text
    global _start
    extern printf, exp, pow                  ; Используем внешние функции printf, exp, pow

_start:
    ; Инициализация
    mov rdi, table_title                     ; Печать заголовка таблицы
    call printf

    fld qword [start_x]                      ; Загружаем начальное значение x
    fstp qword [x_value]                     ; Сохраняем его в x_value

.loop:
    ; Вычисляем 1/x
    fld1                                     ; Загружаем 1
    fld qword [x_value]                      ; Загружаем x
    fdiv st1, st0                            ; 1 / x
    fstp qword [one]                         ; Сохраняем результат в one

    ; Вычисляем exp(1/x)
    mov rdi, one                             ; Передаём 1/x в exp
    call exp                                 ; Вызываем exp(1/x)
    fstp qword [result]                      ; Сохраняем результат exp(1/x)

    ; Умножаем на x^2
    fld qword [x_value]                      ; Загружаем x
    fld st0                                  ; Дублируем x
    fmul st0, st1                            ; x^2
    fmul qword [result]                      ; x^2 * exp(1/x)
    fstp qword [result]                      ; Сохраняем результат в result

    ; Вывод значения в формате
    lea rdi, [format]                        ; Формат строки
    mov rsi, qword [x_value]                 ; Текущее значение x
    mov rdx, qword [result]                  ; Результат y
    call printf                              ; Печать x и y

    ; Увеличиваем x на шаг h
    fld qword [x_value]                      ; Загружаем x
    fld qword [h]                            ; Загружаем шаг h
    faddp st1, st0                           ; x + h
    fstp qword [x_value]                     ; Сохраняем новое значение x

    ; Проверка выхода за пределы end_x
    fld qword [x_value]                      ; Загружаем x
    fld qword [end_x]                        ; Загружаем конец диапазона
    fcomi st0, st1                           ; Сравниваем x и end_x
    jbe .loop                                ; Если x <= end_x, продолжаем цикл

    ; Завершение программы
    mov eax, 60                              ; syscall: exit
    xor edi, edi                             ; статус выхода: 0
    syscall

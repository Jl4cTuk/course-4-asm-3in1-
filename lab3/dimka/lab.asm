section .bss
    a resd 1
    b resd 1
    c resd 1
    x1 resd 1
    x2 resd 1
    discr resd 1
    sqrt_res resd 1
    buffer resb 32

section .data
    msg_a db 'a: ', 0
    msg_b db 'b: ', 0
    msg_c db 'c: ', 0
    msg_x1 db 'x1 = ', 0
    msg_x2 db 'x2 = ', 0
    msg_D db 'D = ', 0
    msg_no_roots db 'Нет вещественных корней', 0
    newline db 0xA
    err_a_zero db 'Ошибка: a не может быть 0', 0

section .text
    global _start

_start:
    ; Вывод сообщения и ввод a
    mov eax, 4             ; sys_write
    mov ebx, 1             ; stdout
    mov ecx, msg_a
    mov edx, 3
    int 0x80

    mov eax, 3             ; sys_read
    mov ebx, 0             ; stdin
    mov ecx, buffer
    mov edx, 32
    int 0x80
    call string_to_int
    mov [a], eax

    ; Проверка, что a != 0
    cmp dword [a], 0
    je error_a_zero

    ; Вывод сообщения и ввод b
    mov eax, 4             ; sys_write
    mov ebx, 1             ; stdout
    mov ecx, msg_b
    mov edx, 3
    int 0x80

    mov eax, 3             ; sys_read
    mov ebx, 0             ; stdin
    mov ecx, buffer
    mov edx, 32
    int 0x80
    call string_to_int
    mov [b], eax

    ; Вывод сообщения и ввод c
    mov eax, 4             ; sys_write
    mov ebx, 1             ; stdout
    mov ecx, msg_c
    mov edx, 3
    int 0x80

    mov eax, 3             ; sys_read
    mov ebx, 0             ; stdin
    mov ecx, buffer
    mov edx, 32
    int 0x80
    call string_to_int
    mov [c], eax

    ; Вычисление дискриминанта D = b^2 - 4ac
    mov eax, [b]
    imul eax, eax          ; b^2
    mov ebx, [a]
    mov ecx, [c]
    imul ebx, ecx          ; a * c
    imul ebx, 4            ; 4ac
    sub eax, ebx           ; D = b^2 - 4ac
    mov [discr], eax

    ; Вывод дискриминанта
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    mov ecx, msg_D
    mov edx, 4
    int 0x80

    mov eax, [discr]
    call print_int

    ; Вывод перевода строки
    mov eax, 4              ; sys_write
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Проверка дискриминанта
    cmp dword [discr], 0
    jl no_real_roots         ; Если D < 0, переход к no_real_roots
    je d_zero                ; Если D = 0, переход к d_zero

    ; Если D > 0, вычисляем sqrt(D)
    mov eax, [discr]
    call sqrt
    mov [sqrt_res], eax

    ; Переход к вычислению корней
    jmp compute_roots

d_zero:
    ; Если D = 0, sqrt(D) = 0
    mov dword [sqrt_res], 0

compute_roots:
    ; Вычисление x1 = (-b + sqrt(D)) / (2a)
    mov eax, [b]
    neg eax                 ; -b
    mov ebx, [sqrt_res]
    add eax, ebx            ; (-b) + sqrt(D)
    mov ebx, [a]
    shl ebx, 1              ; 2a
    cdq                     ; Подготовка для idiv (знаковый)    ???
    idiv ebx                ; EAX = EAX / EBX
    mov [x1], eax

    ; Вычисление x2 = (-b - sqrt(D)) / (2a)
    mov eax, [b]
    neg eax                 ; -b
    mov ebx, [sqrt_res]
    sub eax, ebx            ; (-b) - sqrt(D)
    mov ebx, [a]
    shl ebx, 1              ; 2a
    cdq                     ; Подготовка для idiv (знаковый)
    idiv ebx                ; EAX = EAX / EBX
    mov [x2], eax

    ; Вывод корня x1
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    mov ecx, msg_x1
    mov edx, 5
    int 0x80

    mov eax, [x1]
    call print_int

    ; Вывод перевода строки
    mov eax, 4              ; sys_write
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Вывод корня x2
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    mov ecx, msg_x2
    mov edx, 5
    int 0x80

    mov eax, [x2]
    call print_int

    ; Вывод перевода строки
    mov eax, 4              ; sys_write
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    jmp exit_program

no_real_roots:
    ; Вывод сообщения о том, что корней нет
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    mov ecx, msg_no_roots
    mov edx, 14
    int 0x80

    ; Вывод перевода строки
    mov eax, 4              ; sys_write
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    jmp exit_program

error_a_zero:
    ; Вывод сообщения об ошибке, если a = 0
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    mov ecx, err_a_zero
    mov edx, 23
    int 0x80

    ; Вывод перевода строки
    mov eax, 4              ; sys_write
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    jmp exit_program

exit_program:
    ; Завершение программы
    mov eax, 1              ; sys_exit
    xor ebx, ebx            ; Код возврата 0
    int 0x80

; Функция для преобразования строки в число (исправленная)
string_to_int:
    xor eax, eax            ; Очистить EAX
    xor ebx, ebx            ; Очистить EBX
    mov edx, 0              ; Очистить EDX

    mov bl, [ecx]
    cmp bl, '-'             ; Проверка на знак отрицательного числа
    jne convert_loop
    mov edx, 1              ; Флаг отрицательного числа
    inc ecx                 ; Перейти к следующему символу

convert_loop:
    mov bl, [ecx]
    cmp bl, 0xA             ; Проверка на символ перевода строки
    je end_convert
    cmp bl, 0                ; Проверка на конец строки
    je end_convert
    sub bl, '0'              ; Преобразование ASCII символа в цифру
    imul eax, eax, 10        ; Умножение текущего числа на 10
    movzx ebx, bl            ; Расширение bl до 32 бит и сохранение в ebx
    add eax, ebx             ; Добавление новой цифры (исправлено)
    inc ecx                   ; Переход к следующему символу
    jmp convert_loop

end_convert:
    cmp edx, 1
    jne no_negative
    neg eax                  ; Если число отрицательное, инвертировать знак

no_negative:
    ret

; Функция для вывода целого числа с правильным размещением знака минус
print_int:
    push eax                 ; Сохранить EAX
    push ebx                 ; Сохранить EBX
    push ecx                 ; Сохранить ECX
    push edx                 ; Сохранить EDX
    push esi                 ; Сохранить ESI (будет использоваться как флаг отрицательного числа)

    mov ecx, buffer + 32     ; Установить указатель на конец буфера
    mov ebx, 10              ; Основание системы счисления
    xor esi, esi             ; Обнулить ESI (флаг отрицательного числа)

    ; Проверка, является ли число отрицательным
    cmp eax, 0
    jge convert_positive
    neg eax                  ; Сделать число положительным
    mov esi, 1               ; Установить флаг отрицательного числа
convert_positive:
    ; Цикл преобразования числа в строку
convert_loop_print:
    xor edx, edx             ; Обнулить EDX перед делением
    div ebx                  ; Деление EAX на 10
    add dl, '0'              ; Преобразовать остаток в ASCII символ
    dec ecx                  ; Переместить указатель назад
    mov [ecx], dl            ; Сохранить символ в буфер
    test eax, eax            ; Проверить, не равно ли число 0
    jnz convert_loop_print   ; Если не равно, продолжить цикл

    ; Если число было отрицательным, добавить '-' перед цифрами
    cmp esi, 1
    jne skip_minus
    dec ecx                  ; Переместить указатель назад для знака '-'
    mov byte [ecx], '-'      ; Поместить '-' в буфер
skip_minus:

    ; Вычисление длины строки
    lea edi, [buffer + 32]  ;???
    sub edi, ecx             ; EDI = длина строки

    ; Вывод строки
    mov eax, 4               ; sys_write
    mov ebx, 1               ; stdout
    mov edx, edi             ; Длина строки
    ; ECX уже указывает на начало строки
    int 0x80                 ; Вызов системного прерывания

    pop esi                  ; Восстановить ESI
    pop edx                  ; Восстановить EDX
    pop ecx                  ; Восстановить ECX
    pop ebx                  ; Восстановить EBX
    pop eax                  ; Восстановить EAX
    ret

; Функция для нахождения квадратного корня (улучшенная)
sqrt:
    ; Вход: EAX содержит число, для которого нужно найти квадратный корень
    ; Выход: EAX содержит приближённое значение квадратного корня

    cmp eax, 0
    je sqrt_done             ; Если D=0, sqrt(D)=0

    mov ebx, eax             ; Сохранить исходное число в EBX
    mov eax, 1               ; Начальное приближение
    mov ecx, 0               ; Счётчик итераций

sqrt_loop:
    mov edx, 0
    div ebx                  ; EAX = EAX / EBX
    add eax, ebx             ; EAX = EAX / EBX + EBX
    shr eax, 1               ; Деление на 2
    cmp eax, ebx
    je sqrt_done
    mov ebx, eax             ; Обновить EBX для следующей итерации
    inc ecx
    cmp ecx, 20              ; Ограничение количества итераций
    jl sqrt_loop    ;вывод сообщения сделать

sqrt_done:
    ret
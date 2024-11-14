section .bss
    m resd 1               ; переменная для хранения m
    n resd 1               ; переменная для хранения n
    limit resd 1           ; переменная для хранения результата умножения m и n
    current resd 1         ; переменная для текущего кратного
    min_value resd 1       ; переменная для минимального значения между m и n
    buffer resb 12         ; буфер для вывода числа

section .data
    newline db 10           ; символ новой строки
    prompt1 db 'm: ', 0     ; приглашение для m
    prompt2 db 'n: ', 0     ; приглашение для n
    limit_msg db 'Limit: ', 0
    common_msg db 'Common multiples:', 10, 0 ; сообщение с переводом строки

section .text
    global _start

_start:
    ; Выводим приглашение для ввода m
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt1
    mov edx, 3
    int 0x80

    ; Читаем m
    mov eax, 3
    mov ebx, 0
    mov ecx, m
    mov edx, 10
    int 0x80

    ; Преобразуем m в число
    mov ecx, m
    call str_to_num
    mov [m], eax            ; сохраняем значение m в переменной m

    ; Выводим приглашение для ввода n
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt2
    mov edx, 3
    int 0x80

    ; Читаем n
    mov eax, 3
    mov ebx, 0
    mov ecx, n
    mov edx, 10
    int 0x80

    ; Преобразуем n в число
    mov ecx, n
    call str_to_num
    mov [n], eax            ; сохраняем значение n в переменной n

    ; Умножаем m на n и сохраняем результат в limit
    xor edx, edx            ; сбрасываем edx перед умножением
    mov eax, [m]            ; eax = m
    mul dword [n]           ; умножаем m на n (eax = m * n, результат в eax и edx)
    mov [limit], eax        ; сохраняем результат умножения в limit

    ; Выводим сообщение 'Limit: '
    mov eax, 4
    mov ebx, 1
    mov ecx, limit_msg
    mov edx, 7
    int 0x80

    ; Загружаем значение limit для вывода
    mov eax, [limit]
    call print_number

    ; Определяем минимальное из m и n и записываем в min_value
    mov eax, [m]            ; загружаем m в eax
    mov ebx, [n]            ; загружаем n в ebx
    cmp eax, ebx            ; сравниваем m и n
    jle set_min_m           ; если m <= n, то выбираем m
    mov eax, ebx            ; min_value = n
    jmp set_min_done

set_min_m:
    mov eax, [m]            ; min_value = m

set_min_done:
    mov [min_value], eax     ; сохраняем минимальное значение в min_value
    mov [current], eax       ; устанавливаем текущее значение current = min_value

    ; Выводим сообщение 'Common multiples:'
    mov eax, 4
    mov ebx, 1
    mov ecx, common_msg
    mov edx, 20             ; длина сообщения с переводом строки
    int 0x80

    ; Цикл для поиска кратных
find_multiples:
    mov eax, [current]      ; загружаем значение current
    cmp eax, [limit]        ; сравниваем current с limit
    jge end_program         ; если current >= limit, заканчиваем цикл

    ; Проверяем, делится ли current на m
    xor edx, edx            ; очищаем edx перед делением
    mov ebx, [m]            ; загружаем m в ebx
    div ebx                 ; делим current на m
    test edx, edx           ; проверяем остаток
    jnz not_multiple        ; если не делится на m, переход к следующему шагу

    ; Проверяем, делится ли current на n
    mov eax, [current]
    xor edx, edx
    mov ebx, [n]            ; загружаем n в ebx
    div ebx                 ; делим current на n
    test edx, edx           ; проверяем остаток
    jnz not_multiple        ; если не делится на n, переход к следующему шагу

    ; Если current делится на m и n, выводим его
    mov eax, [current]
    call print_number

not_multiple:
    ; Увеличиваем current на минимальное значение (min(m, n))
    mov eax, [current]
    add eax, [min_value]
    mov [current], eax
    jmp find_multiples      ; повторяем цикл

end_program:
    ; Завершаем программу
    mov eax, 1
    mov ebx, 0
    int 0x80

; Функция для преобразования строки в число
str_to_num:
    xor eax, eax            ; eax будет содержать результат

convert_loop:
    mov bl, [ecx]
    cmp bl, 10              ; проверяем символ новой строки '\n'
    je convert_done
    cmp bl, 13              ; проверяем символ возврата каретки '\r'
    je convert_done
    cmp bl, '0'
    jb invalid_input        ; если символ меньше '0', это не цифра
    cmp bl, '9'
    ja invalid_input        ; если символ больше '9', это не цифра
    sub bl, '0'             ; преобразуем ASCII символ в цифру (0-9)
    imul eax, eax, 10       ; умножаем текущий результат на 10
    add eax, ebx            ; добавляем текущую цифру к результату
    inc ecx
    jmp convert_loop

convert_done:
    ret

invalid_input:
    ; Здесь вы можете обработать неверный ввод (например, завершить программу с ошибкой)
    mov eax, 1              ; sys_exit
    mov ebx, 1              ; статус ошибки
    int 0x80

; Функция для вывода числа без обработки отрицательных чисел
print_number:
    push eax                 ; Сохранить EAX
    mov ecx, buffer + 12     ; Установить указатель на конец буфера
    mov ebx, 10              ; Основание системы счисления

convert_loop_print:
    xor edx, edx             ; Обнулить EDX перед делением
    div ebx                  ; Деление EAX на 10
    add dl, '0'              ; Преобразовать остаток в ASCII символ
    dec ecx                  ; Переместить указатель назад
    mov [ecx], dl            ; Сохранить символ в буфер
    test eax, eax            ; Проверить, не равно ли число 0
    jnz convert_loop_print   ; Если не равно, продолжить цикл

    ; Вычисление длины строки
    lea edi, [buffer + 12]   ; Указатель на конец буфера
    sub edi, ecx             ; Длина строки = разница между концом буфера и указателем

    ; Вывод строки
    mov eax, 4               ; sys_write
    mov ebx, 1               ; stdout
    mov edx, edi             ; Длина строки
    mov ecx, ecx             ; Указатель на начало строки
    int 0x80                 ; Вызов системного прерывания

    ; Выводим перевод строки
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    pop eax                  ; Восстановить EAX
    ret

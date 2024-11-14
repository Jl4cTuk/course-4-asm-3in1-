section .bss
    m resd 1               ; переменная для хранения m
    n resd 1               ; переменная для хранения n
    gcd_value resd 1       ; НОД
    divisor_value resd 1   ; текущий делитель
    buffer resb 12         ; буфер для вывода числа

section .data
    newline db 10           ; символ новой строки
    space_dash db ' -', 0   ; строка для вывода " -"
    prompt1 db 'm: ', 0     ; приглашение для m
    prompt2 db 'n: ', 0     ; приглашение для n
    gcd_msg db 'GCD: ', 0   ; сообщение для вывода НОД
    div_msg db 'Divisors: ', 0 ; сообщение для вывода делителей

section .text
    global _start

_start:
    ; Ввод m
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt1
    mov edx, 3
    int 0x80

    ; Чтение m
    mov eax, 3
    mov ebx, 0
    mov ecx, m
    mov edx, 10
    int 0x80

    ; Преобразование m в число с проверкой на знак
    mov ecx, m
    call str_to_num_with_sign
    test eax, eax
    jge .skip_neg_m          ; если положительное
    neg eax                  ; если отрицательное, делаем его положительным
.skip_neg_m:
    mov [m], eax             ; сохраняем значение m

    ; Ввод n
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt2
    mov edx, 3
    int 0x80

    ; Чтение n
    mov eax, 3
    mov ebx, 0
    mov ecx, n
    mov edx, 10
    int 0x80

    ; Преобразование n в число с проверкой на знак
    mov ecx, n
    call str_to_num_with_sign
    test eax, eax
    jge .skip_neg_n          ; если положительное
    neg eax                  ; если отрицательное, делаем его положительным
.skip_neg_n:
    mov [n], eax             ; сохраняем значение n

    ; Вычисление НОД
    mov eax, [m]
    mov ebx, [n]
    call gcd
    mov [gcd_value], eax     ; сохраняем НОД

    ; Выводим НОД
    mov eax, 4
    mov ebx, 1
    mov ecx, gcd_msg
    mov edx, 5
    int 0x80

    mov eax, [gcd_value]
    call print_number

    ; Выводим перевод строки
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Выводим сообщение 'Divisors:'
    mov eax, 4
    mov ebx, 1
    mov ecx, div_msg
    mov edx, 10
    int 0x80

    ; Выводим перевод строки
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Цикл для вывода всех делителей НОД
    mov eax, [gcd_value]
    call print_divisors

    ; Завершаем программу
    mov eax, 1
    xor ebx, ebx
    int 0x80

; Функция для нахождения НОД (алгоритм Евклида)
gcd:
    push ebx
.loop:
    test ebx, ebx
    jz .done
    xor edx, edx
    div ebx
    mov eax, ebx
    mov ebx, edx
    jmp .loop
.done:
    pop ebx
    ret

; Функция для вывода делителей НОД (положительных и отрицательных)
print_divisors:
    push eax                      ; сохранить EAX
    mov eax, [gcd_value]           ; загружаем НОД в eax
    mov ebx, eax                   ; сохраняем НОД в ebx для дальнейших операций

    ; Инициализируем divisor_value
    mov dword [divisor_value], 1   ; начинаем с делителя 1

.div_loop:
    mov eax, [divisor_value]       ; загружаем текущее значение делителя
    cmp eax, [gcd_value]           ; проверяем, достигли ли мы значения НОД
    jg .done_divisors              ; если делитель больше НОД, заканчиваем

    ; Проверяем, является ли divisor_value делителем gcd_value
    mov eax, [gcd_value]
    cdq                            ; расширяем EAX на EDX для деления
    div dword [divisor_value]      ; делим НОД на текущий делитель
    test edx, edx                  ; проверяем остаток
    jnz .next_div                  ; если не делится нацело, пропускаем

    ; Выводим положительный делитель
    mov eax, [divisor_value]
    call print_number

    ; Выводим строку ' -'
    mov eax, 4
    mov ebx, 1
    mov ecx, space_dash
    mov edx, 2
    int 0x80

    ; Выводим отрицательный делитель (умножаем на -1)
    mov eax, [divisor_value]
    call print_number

    ; Выводим перевод строки
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

.next_div:
    inc dword [divisor_value]      ; увеличиваем значение делителя на 1
    jmp .div_loop                  ; продолжаем цикл

.done_divisors:
    pop eax                        ; восстановить EAX
    ret

; Функция для преобразования строки в число с проверкой на знак
str_to_num_with_sign:
    xor eax, eax             ; eax будет содержать результат
    xor edx, edx             ; edx используется для хранения знака (0 - положительное, 1 - отрицательное)

    ; Проверяем первый символ на минус
    mov bl, [ecx]
    cmp bl, '-'
    jne convert_loop         ; если не минус, продолжаем обычное преобразование
    inc ecx                  ; пропускаем минус
    inc edx                  ; устанавливаем флаг, что число отрицательное

convert_loop:
    mov bl, [ecx]
    cmp bl, 10               ; проверяем символ новой строки '\n'
    je convert_done
    cmp bl, 13               ; проверяем символ возврата каретки '\r'
    je convert_done
    cmp bl, '0'
    jb invalid_input         ; если символ меньше '0', это не цифра
    cmp bl, '9'
    ja invalid_input         ; если символ больше '9', это не цифра
    sub bl, '0'              ; преобразуем ASCII символ в цифру (0-9)
    imul eax, eax, 10        ; умножаем текущий результат на 10
    add eax, ebx             ; добавляем текущую цифру к результату
    inc ecx
    jmp convert_loop

convert_done:
    cmp edx, 1               ; проверяем, установлен ли флаг отрицательного числа
    jne done_neg_check
    neg eax                  ; если да, делаем число отрицательным

done_neg_check:
    ret

invalid_input:
    ; Здесь вы можете обработать неверный ввод (например, завершить программу с ошибкой)
    mov eax, 1               ; sys_exit
    mov ebx, 1               ; статус ошибки
    int 0x80

; Функция для вывода числа без обработки отрицательных чисел
print_number:
    push eax                 ; сохранить EAX
    mov ecx, buffer + 12     ; установить указатель на конец буфера
    mov ebx, 10              ; основание системы счисления

convert_loop_print:
    xor edx, edx             ; обнулить EDX перед делением
    div ebx                  ; деление EAX на 10
    add dl, '0'              ; преобразовать остаток в ASCII символ
    dec ecx                  ; переместить указатель назад
    mov [ecx], dl            ; сохранить символ в буфер
    test eax, eax            ; проверить, не равно ли число 0
    jnz convert_loop_print   ; если не равно, продолжить цикл

    ; Вычисление длины строки
    lea edi, [buffer + 12]   ; указатель на конец буфера
    sub edi, ecx             ; длина строки = разница между концом буфера и указателем

    ; Сохранить указатель начала строки
    mov esi, ecx             ; сохраняем указатель на начало строки в esi

    ; Вывод строки
    mov eax, 4               ; sys_write
    mov ebx, 1               ; stdout
    mov ecx, esi             ; указатель на начало строки
    mov edx, edi             ; длина строки
    int 0x80                 ; вызов системного прерывания

    pop eax                  ; восстановить EAX
    ret

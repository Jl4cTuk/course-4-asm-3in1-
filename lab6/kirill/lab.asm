section .data
    X dd 5, 3, 7, 3, 9, 3, 2, 3, 8, 3     ; Исходный массив X
    len equ 10                            ; Количество элементов в массиве X
    b dd 3                                ; Значение, которое нужно исключить
    newline db 10                         ; Символ новой строки
    space db 32                           ; Пробел для форматирования вывода

section .bss
    result resd len                       ; Массив для хранения результата
    buffer resb 5                         ; Буфер для вывода числа (4 цифры + завершающий ноль)

section .text
    global _start

_start:
    mov esi, 0                            ; Индекс для исходного массива X
    mov edi, 0                            ; Индекс для массива результата

filter_loop:
    cmp esi, len                          ; Проверка на конец массива
    jge end_filter                        ; Если достигли конца массива, выходим из цикла

    mov eax, [X + esi*4]                  ; Загружаем элемент X[esi]
    cmp eax, [b]                          ; Сравниваем элемент с b
    je skip_element                       ; Если равно b, пропускаем элемент

    mov [result + edi*4], eax             ; Сохраняем элемент в массив result
    inc edi                               ; Увеличиваем индекс для result

skip_element:
    inc esi                               ; Переходим к следующему элементу
    jmp filter_loop

end_filter:
    ; Вывод массива result
    mov esi, 0                            ; Сброс индекса для результата

print_loop:
    cmp esi, edi                          ; Проверка на конец массива result
    jge end_print                         ; Если достигли конца массива, выходим из цикла

    mov eax, [result + esi*4]             ; Загружаем элемент result[esi]
    call print_num                        ; Выводим элемент
    inc esi                               ; Переходим к следующему элементу
    jmp print_loop

end_print:
    mov eax, 1                            ; Завершаем программу
    mov ebx, 0
    int 0x80

print_num:
    push edi                           ; Save EDI
    push ebx                           ; Save EBX if you're using it

    mov ebx, eax                       ; Copy the number to EBX for conversion

    ; Convert the number to a string
    mov ecx, 10                        ; Base 10
    mov edi, buffer + 4                ; Point to the end of the buffer
    mov byte [edi], 0                  ; Null-terminate the string

print_digit:
    dec edi
    xor edx, edx
    div ecx                            ; EAX / 10, remainder in EDX
    add dl, '0'                        ; Convert digit to ASCII
    mov [edi], dl                      ; Store the digit
    test eax, eax                      ; Check if EAX is zero
    jnz print_digit

    ; Write the string to stdout
    mov eax, 4                         ; sys_write
    mov ebx, 1                         ; stdout
    mov ecx, edi                       ; Pointer to the string
    mov edx, buffer + 4                ; End of the buffer
    sub edx, edi                       ; Calculate the length
    int 0x80

    ; Write a newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    pop ebx                            ; Restore EBX if you saved it
    pop edi                            ; Restore EDI
    ret
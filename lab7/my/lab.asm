section .data
matrix dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36
n equ 6
newline db 10                       ; Символ новой строки

section .bss
total_sum resd 1                    ; Переменная для хранения итоговой суммы
buffer resb 5                       ; Буфер для вывода числа (4 цифры + завершающий ноль)

section .text
global _start

_start:
    mov eax, 0                          ; Обнуляем итоговую сумму
    mov [total_sum], eax

    ; Считаем верхнюю часть пирамиды до центра
    mov ecx, 0                          ; Индекс строки
upper_sum_loop:
    cmp ecx, n                          ; Проверяем, не достигли ли середины матрицы
    jge lower_sum                       ; Переход к нижней части пирамиды, если достигли середины

    ; Вычисляем сумму строки от i до n-i-1
    mov edi, ecx                        ; Начало индекса для строки
    mov edx, n                          ; Конец строки
    sub edx, ecx                        ; Диапазон суммирования: от `i` до `n-i-1`
inner_upper_loop:
    cmp edi, edx                        ; Проверка на конец диапазона строки
    jge end_inner_upper

    ; Получаем элемент matrix[ecx * n + edi]
    mov eax, ecx
    imul eax, n                         ; eax = ecx * n
    add eax, edi                        ; eax = ecx * n + edi
    shl eax, 2                          ; Умножаем на 4 для корректного сдвига
    add eax, matrix                     ; Адрес элемента
    mov ebx, [eax]                      ; Получаем значение элемента
    add [total_sum], ebx                ; Добавляем его к общей сумме

    inc edi                             ; Увеличиваем индекс столбца
    jmp inner_upper_loop

end_inner_upper:
    inc ecx                             ; Переход к следующей строке
    jmp upper_sum_loop

lower_sum:
    ; Считаем нижнюю часть пирамиды от центра до конца
    mov ecx, n                          ; Индекс строки для нижней половины
    shr ecx, 1                          ; Начинаем с центральной строки и идем вниз
lower_sum_loop:
    inc ecx
    cmp ecx, n                          ; Проверка на конец матрицы
    jge print_result                    ; Переход к выводу результата

    ; Вычисляем сумму строки от `n - i - 1` до `i`
    mov edi, n
    sub edi, ecx
    dec edi                             ; Начальный индекс столбца
    mov edx, ecx                        ; Конечный индекс столбца
inner_lower_loop:
    cmp edi, edx                        ; Проверка на конец строки
    jg end_inner_lower

    ; Получаем элемент matrix[ecx * n + edi]
    mov eax, ecx
    imul eax, n                         ; eax = ecx * n
    add eax, edi                        ; eax = ecx * n + edi
    shl eax, 2                          ; Умножаем на 4 для корректного сдвига
    add eax, matrix                     ; Адрес элемента
    mov ebx, [eax]                      ; Получаем значение элемента
    add [total_sum], ebx                ; Добавляем его к общей сумме

    inc edi                             ; Увеличиваем индекс столбца
    jmp inner_lower_loop

end_inner_lower:
    jmp lower_sum_loop

print_result:
    ; Выводим итоговую сумму
    mov eax, [total_sum]
    call print_num

    ; Завершаем программу
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_num:
    ; Процедура для вывода числа в консоль
    push edi
    push ebx
    mov ebx, eax
    mov ecx, 10
    mov edi, buffer + 4
    mov byte [edi], 0

print_digit:
    dec edi
    xor edx, edx
    div ecx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz print_digit

    ; Печать числа
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, buffer + 4
    sub edx, edi
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    pop ebx
    pop edi
    ret

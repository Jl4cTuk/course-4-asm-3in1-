section .data

    ROWS_A equ 2
    COLS_A equ 3

    ROWS_B equ 3
    COLS_B equ 2

    A dd 1, 2, 3, 4, 5, 6
    B dd 7, 8, 9, 10, 11, 12

    newline db 10      ; Символ новой строки
    space   db ' '     ; Пробел

section .bss
    result resd ROWS_A * COLS_B   ; Матрица результата (2x2)
    buffer resb 12                ; Буфер для вывода числа

section .text
    global _start

_start:
    ; Инициализация переменной i = 0
    mov esi, 0

outer_loop_i:
    cmp esi, ROWS_A
    jge end_outer_loop_i

    ; Инициализация переменной j = 0
    mov edi, 0

loop_j:
    cmp edi, COLS_B
    jge end_loop_j

    ; result[i][j] = 0
    mov eax, esi
    imul eax, COLS_B           ; eax = i * COLS_B
    add eax, edi               ; eax = i * COLS_B + j
    shl eax, 2                 ; Умножаем на 4 (размер int)
    mov ecx, eax               ; ecx хранит смещение для result[i][j]

    mov dword [result + ecx], 0

    ; Инициализация переменной k = 0
    mov ebp, 0   ; Используем ebp как счетчик k

loop_k:
    cmp ebp, COLS_A
    jge end_loop_k

    ; Вычисляем A[i][k] * B[k][j] и добавляем к result[i][j]
    ; Вычисление индекса для A[i][k]
    mov eax, esi
    imul eax, COLS_A           ; eax = i * COLS_A
    add eax, ebp               ; eax = i * COLS_A + k
    shl eax, 2                 ; Умножаем на 4
    mov edx, eax               ; edx хранит смещение для A[i][k]

    ; Загружаем A[i][k] в eax
    mov eax, [A + edx]

    ; Вычисление индекса для B[k][j]
    mov edx, ebp
    imul edx, COLS_B           ; edx = k * COLS_B
    add edx, edi               ; edx = k * COLS_B + j
    shl edx, 2                 ; Умножаем на 4

    ; Загружаем B[k][j] в ebx (временное хранение)
    mov ebx, [B + edx]

    ; Умножаем A[i][k] на B[k][j]
    imul eax, ebx              ; eax = A[i][k] * B[k][j]

    ; Добавляем к result[i][j]
    mov ebx, [result + ecx]
    add ebx, eax
    mov [result + ecx], ebx

    ; Увеличиваем k
    inc ebp
    jmp loop_k

end_loop_k:
    ; Увеличиваем j
    inc edi
    jmp loop_j

end_loop_j:
    ; Увеличиваем i
    inc esi
    jmp outer_loop_i

end_outer_loop_i:
    ; Выводим матрицу результата
    mov esi, 0  ; i = 0

print_loop_i:
    cmp esi, ROWS_A
    jge end_print_loop_i

    mov edi, 0  ; j = 0

print_loop_j:
    cmp edi, COLS_B
    jge end_print_loop_j

    ; Вычисляем индекс result[i][j]
    mov eax, esi
    imul eax, COLS_B
    add eax, edi
    shl eax, 2
    mov ecx, eax

    ; Загружаем result[i][j] в eax
    mov eax, [result + ecx]

    ; Вызываем процедуру вывода числа
    call print_num

    ; Печатаем пробел
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

    ; Увеличиваем j
    inc edi
    jmp print_loop_j

end_print_loop_j:
    ; Печатаем новую строку
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Увеличиваем i
    inc esi
    jmp print_loop_i

end_print_loop_i:
    ; Завершаем программу
    mov eax, 1
    xor ebx, ebx
    int 0x80

; Процедура вывода числа
print_num:
    ; eax содержит число для вывода
    push ebp     ; Сохраняем регистр ebp
    push ebx
    push ecx
    push edx
    push esi

    mov esi, buffer + 11   ; Устанавливаем указатель в конец буфера
    mov byte [esi], 0      ; Завершаем строку нулевым символом

    mov ebx, 10            ; Основание системы счисления

    ; Проверяем, не является ли число нулем
    cmp eax, 0
    jne .print_num_loop
    dec esi
    mov byte [esi], '0'

    jmp .print_num_end

.print_num_loop:
    xor edx, edx
    div ebx
    dec esi
    add dl, '0'
    mov [esi], dl
    test eax, eax
    jnz .print_num_loop

.print_num_end:
    ; Выводим число
    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    mov edx, buffer + 11
    sub edx, esi          ; Длина строки
    int 0x80

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop ebp               ; Восстанавливаем регистр ebp
    ret

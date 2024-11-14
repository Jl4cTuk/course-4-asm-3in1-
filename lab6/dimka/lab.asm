section .data
    found_message db "found", 10  ; Сообщение, если пара найдена
    not_found_message db "not found", 10         ; Сообщение, если пара не найден
    array db -10, 10, -15, 30, -5, 5, -8, 10, -15, 30, -5, 5, -8
    len equ $ - array                            ; Длина массива
    newline db 10

section .bss
    ; Не требуется в данном случае

section .text
    global _start

_start:
    mov ecx, len       ; Количество элементов массива
    mov esi, array     ; Указатель на начало массива

check_sign:
    dec ecx            ; Уменьшаем счетчик (останавливаемся за один элемент до конца массива)
    jz not_found       ; Если достигнут конец массива, выводим "Not found" и выходим

    ; Загружаем два соседних элемента
    mov al, [esi]
    mov bl, [esi + 1]

    ; Проверка на одинаковый знак
    test al, al
    js is_negative1
    jmp is_positive1

is_negative1:
    test bl, bl
    js found_same_sign ; Если оба отрицательные, найдено совпадение
    jmp next_pair

is_positive1:
    test bl, bl
    jns found_same_sign ; Если оба положительные или ноль, найдено совпадение

next_pair:
    inc esi            ; Переход к следующей паре элементов
    jmp check_sign     ; Продолжение проверки

found_same_sign:
    mov eax, 4             ; Системный вызов для вывода (sys_write)
    mov ebx, 1             ; Дескриптор файла (1 = stdout)
    mov ecx, found_message ; Адрес сообщения о найденной паре
    mov edx, 5 ; Длина сообщения
    int 0x80               ; Выполнение системного вызова
    jmp end_program        ; Завершаем программу после первого найденного совпадения

not_found:
    mov eax, 4                 ; Системный вызов для вывода (sys_write)
    mov ebx, 1                 ; Дескриптор файла (1 = stdout)
    mov ecx, not_found_message ; Адрес сообщения, если пара не найдена
    mov edx, 9 ; Длина сообщения
    int 0x80                   ; Выполнение системного вызова

end_program:

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1         ; Системный вызов для выхода (sys_exit)
    mov ebx, 0         ; Код возврата 0
    int 0x80

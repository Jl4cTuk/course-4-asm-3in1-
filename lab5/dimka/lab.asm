section .data
    p dd 5        ; Задайте значение p
    q dd 36        ; Задайте значение q
    newline db 10
    msg db 'delitels: ',10,0

section .bss
    divisor resd 1
    buffer resb 12

section .text
    global _start

_start:
    ; Вывод сообщения
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, 10    ; Длина сообщения
    int 0x80

    ; Инициализация делителя = 1
    mov dword [divisor], 1

divisor_loop:
    mov eax, [divisor]
    cmp eax, [q]
    jg end_program

    ; Проверка, является ли divisor делителем q
    mov eax, [q]
    mov ebx, [divisor]
    cdq
    div ebx
    cmp edx, 0
    jne next_divisor

    ; Вычисление НОД(divisor, p)
    mov eax, [divisor]
    mov ebx, [p]
    call gcd

    ; Если НОД равен 1, выводим делитель
    cmp eax, 1
    jne next_divisor

    ; Вывод делителя
    mov eax, [divisor]
    call print_number

next_divisor:
    ; Увеличиваем делитель на 1
    mov eax, [divisor]
    inc eax
    mov [divisor], eax
    jmp divisor_loop

end_program:
    ; Завершение программы
    mov eax, 1
    mov ebx, 0
    int 0x80

; Функция вычисления НОД
; Вход: eax (divisor), ebx (p)
; Выход: eax = НОД(divisor, p)
gcd:
    push edi
gcd_loop:
    cmp ebx, 0
    je gcd_done
    mov edx, 0
    div ebx
    mov edi, ebx
    mov ebx, edx
    mov eax, edi
    jmp gcd_loop

gcd_done:
    pop edi
    ret

; Функция вывода числа в eax
print_number:
    push eax
    mov ecx, buffer
    add ecx, 11   ; Указываем на конец буфера
    mov byte [ecx], 0  ; Завершающий нуль
    cmp eax, 0
    jne print_number_loop

    ; Обработка случая, когда число равно 0
    dec ecx
    mov byte [ecx], '0'
    jmp print_number_done

print_number_loop:
    mov edx, 0
    mov ebx, 10
    div ebx        ; Делим eax на 10
    dec ecx
    add dl, '0'
    mov [ecx], dl
    cmp eax, 0
    jne print_number_loop

print_number_done:
    mov eax, 4
    mov ebx, 1
    mov edx, buffer+11
    sub edx, ecx   ; Длина строки
    mov ecx, ecx   ; Начало строки
    int 0x80

    ; Вывод перевода строки
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    pop eax
    ret

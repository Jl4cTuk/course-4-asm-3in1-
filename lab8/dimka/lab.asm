section .data
    n dd 3

    msg_min db "min vec:  ",0
    msg_max db "max vec:  ",0
    msg_vector db "your vec: ",0
    msg_not_in_interval db "not belong", 0xA,0
    msg_in_interval db "belong", 0xA,0
    newline db 0xA

section .bss
    min_vector resd 1
    max_vector resd 1
    check_vector resd 1

section .text
    global _start

_start:
    ; Ввод нижней границы
    mov eax,4
    mov ebx,1
    mov ecx,msg_min
    mov edx,10
    int 0x80

    mov eax,3
    mov ebx,0
    mov ecx,min_vector
    mov edx,32
    int 0x80

    call min_to_bool_vector

    ; Ввод верхней границы
    mov eax,4
    mov ebx,1
    mov ecx,msg_max
    mov edx,10
    int 0x80

    mov eax,3
    mov ebx,0
    mov ecx,max_vector
    mov edx,32
    int 0x80

    call max_to_bool_vector

    ; Ввод проверяемого вектора
    mov eax,4
    mov ebx,1
    mov ecx,msg_vector
    mov edx,10
    int 0x80

    mov eax,3
    mov ebx,0
    mov ecx,check_vector
    mov edx,32
    int 0x80

    call check_to_bool_vector

    ; Проверяем что min_vector предшествует check_vector
    mov esi, [min_vector]
    mov edi, [check_vector]
    mov ecx, [n]
    call are_comparable
    cmp eax, 1
    je not_in_interval

    ; Проверяем что check_vector предшествует max_vector
    mov esi, [check_vector]
    mov edi, [max_vector]
    mov ecx, [n]
    call are_comparable
    cmp eax, 1
    je not_in_interval

    jmp in_interval

min_to_bool_vector:
    push ebx
    push esi
    push ecx
    push edx

    mov esi, min_vector   ; esi указывает на буфер ввода
    xor eax, eax          ; eax будет аккумулировать биты
    xor ecx, ecx          ; ecx - счетчик бит
    .read_min_bits:
        mov dl, [esi]
        cmp dl, 0xA           ; конец строки?
        je .done_min_bits

        cmp dl, '1'
        je .set_min_bit
        cmp dl, '0'
        je .next_min_bit
        jmp .invalid_min

    .set_min_bit:
        ; Устанавливаем бит номер ecx в eax
        bts eax, ecx

    .next_min_bit:
        inc esi
        inc ecx
        jmp .read_min_bits

    .invalid_min:
        mov eax,1
        mov ebx,1
        int 0x80

    .done_min_bits:
        mov [n], ecx          ; Сохраняем реальное количество бит
        mov [min_vector], eax ; Сохраняем упакованные биты
        pop edx
        pop ecx
        pop esi
        pop ebx
        ret

; Преобразование max_vector
max_to_bool_vector:
    push ebx
    push esi
    push ecx
    push edx

    mov esi, max_vector
    xor eax, eax
    xor ecx, ecx
    .read_max_bits:
        mov dl, [esi]
        cmp dl, 0xA
        je .done_max_bits

        cmp dl, '1'
        je .set_max_bit
        cmp dl, '0'
        je .next_max_bit
        jmp .invalid_max

    .set_max_bit:
        bts eax, ecx

    .next_max_bit:
        inc esi
        inc ecx
        jmp .read_max_bits

    .invalid_max:
        mov eax,1
        mov ebx,1
        int 0x80

    .done_max_bits:
        mov [n], ecx
        mov [max_vector], eax
        pop edx
        pop ecx
        pop esi
        pop ebx
        ret

; Преобразование check_vector
check_to_bool_vector:
    push ebx
    push esi
    push ecx
    push edx

    mov esi, check_vector
    xor eax, eax
    xor ecx, ecx
    .read_check_bits:
        mov dl, [esi]
        cmp dl, 0xA
        je .done_check_bits

        cmp dl, '1'
        je .set_check_bit
        cmp dl, '0'
        je .next_check_bit
        jmp .invalid_check

    .set_check_bit:
        bts eax, ecx

    .next_check_bit:
        inc esi
        inc ecx
        jmp .read_check_bits

    .invalid_check:
        mov eax,1
        mov ebx,1
        int 0x80

    .done_check_bits:
        mov [n], ecx
        mov [check_vector], eax
        pop edx
        pop ecx
        pop esi
        pop ebx
        ret

are_comparable:
    mov edx, 0
    .check_bits:
        test esi, 1
        jz .next_bit
        test edi, 1
        jnz .next_bit

        ; Нашли бит, установленный в A (ESI), но не в B (EDI)
        mov edx, 1
        jmp .done_check

    .next_bit:
        shr esi, 1
        shr edi, 1
        loop .check_bits

    .done_check:
        mov eax, edx
        ret

not_in_interval:
    mov eax,4
    mov ebx,1
    mov ecx,msg_not_in_interval
    mov edx,10
    int 0x80
    jmp exit

in_interval:
    mov eax,4
    mov ebx,1
    mov ecx,msg_in_interval
    mov edx,7
    int 0x80
    jmp exit

exit:
    mov eax,1
    xor ebx,ebx
    int 0x80

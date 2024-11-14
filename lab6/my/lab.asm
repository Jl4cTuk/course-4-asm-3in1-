section .data
    n equ 5
    X dd 3, 7, 10, 15, 20
    Y dd 5, 8, 12, 18, 19
    newline db 10

section .bss
    C resd n
    m resd 1
    buffer resb 5

section .text
    global _start

_start:
    mov ecx, 0
    mov esi, 0

check_loop:
    cmp esi, n
    jge end_check

    mov eax, [X + esi*4]
    mov edi, 0

find_y:
    cmp edi, n
    jge next_x

    mov ebx, [Y + edi*4]
    mov edx, [Y + (edi + 1)*4]  

    cmp eax, ebx
    jle next_y

    cmp eax, edx
    jge next_y

    mov [C + ecx*4], eax
    inc ecx
    jmp next_x

next_y:
    inc edi
    jmp find_y

next_x:
    inc esi
    jmp check_loop

end_check:
    mov [m], ecx

    mov esi, 0

print_loop:
    cmp esi, ecx
    jge end_print

    mov eax, [C + esi*4]
    call print_num
    inc esi
    jmp print_loop

end_print:
    mov eax, 1
    mov ebx, 0
    int 0x80

print_num:
    push ebx
    push ecx
    push edi

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

    mov eax, 4
    mov ebx, 1
    mov ecx, edi

    mov edx, buffer
    add edx, 4
    sub edx, edi

    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    pop edi
    pop ecx
    pop ebx
    ret

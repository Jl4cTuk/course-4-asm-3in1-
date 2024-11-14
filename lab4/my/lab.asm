section .bss
    number resb 100
    sum resb 4

section .data
    newline db 10

section .text
    global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, number
    mov edx, 100
    int 0x80

    mov eax, 0
    mov esi, number

sum_loop:
    mov bl, [esi]
    cmp bl, 10
    je end_sum
    sub bl, '0'
    add eax, ebx
    inc esi
    jmp sum_loop

end_sum:
    mov ebx, 10
    mov edi, 0

convert_sum:
    mov edx, 0
    div ebx
    add dl, '0'
    push dx
    inc edi
    test eax, eax
    jnz convert_sum

print_sum:
    pop dx
    mov eax, 4
    mov ebx, 1
    mov ecx, sum
    mov [ecx], dl
    mov edx, 1
    int 0x80

    dec edi
    jnz print_sum

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1
    mov ebx, 0
    int 0x80

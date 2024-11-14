section .bss
    number resb 4
    sum resb 4

section .data
    newline db 10

section .text
    global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, number
    mov edx, 4
    int 0x80

    mov eax, 0

    sub byte [number], '0'
    add al, [number]

    sub byte [number+1], '0'
    add al, [number+1]

    sub byte [number+2], '0'
    add al, [number+2]

    mov ebx, 10
    mov edi, 0

convert:
    mov edx, 0
    div ebx
    add dl, '0'
    push dx
    inc edi
    test eax, eax
    jnz convert

print:
    pop dx
    mov eax, 4
    mov ebx, 1
    mov ecx, sum
    mov [ecx], dl
    mov edx, 1
    int 0x80

    dec edi
    jnz print

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1
    mov ebx, 0
    int 0x80

section .data
    newline db 10
    space db 32

section .bss
    number resb 4
    buffer resb 4

section .text
    global _start

_start:
    mov dword [number], 100

main_cycle:
    mov eax, [number]
    mov ecx, eax
    mov ebx, 100
    mov esi, 0

hundred:
    cmp ecx, ebx
    jb end_hundred
    sub ecx, ebx
    inc esi
    jmp hundred

end_hundred:
    mov ebx, 10
    mov edi, 0

ten:
    cmp ecx, ebx
    jb end_ten
    sub ecx, ebx
    inc edi
    jmp ten

end_ten:
    cmp esi, edi
    je skip_number
    cmp esi, ecx
    je skip_number
    cmp edi, ecx
    je skip_number

    call print_num

skip_number:
    mov eax, [number]
    inc eax
    mov [number], eax

    cmp eax, 1000
    jb main_cycle

    mov eax, 1
    mov ebx, 0
    int 0x80

print_num:
    mov ebx, buffer

    mov edx, esi
    add dl, '0'
    mov [ebx], dl

    mov edx, edi
    add dl, '0'
    mov [ebx+1], dl

    mov edx, ecx
    add dl, '0'
    mov [ebx+2], dl

    mov byte [ebx+3], 0

    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 3
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ret

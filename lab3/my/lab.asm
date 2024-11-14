section .bss
    a resb 8
    b resb 8
    c resb 8
    result resb 20

section .data
    newline db 10
    triangle_possible db "Triangle possible", 0xA
    triangle_not_possible db "Triangle not possible", 0xA
    equilateral db "Equilateral", 0xA
    isosceles db "Isosceles", 0xA
    scalene db "Scalene", 0xA

section .text
    global _start

_start:

    mov eax, 3
    mov ebx, 0
    mov ecx, a
    mov edx, 8
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, b
    mov edx, 8
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, c
    mov edx, 8
    int 0x80

    mov ecx, a
    call convert_to_number
    mov esi, eax

    mov ecx, b
    call convert_to_number
    mov edi, eax

    mov ecx, c
    call convert_to_number
    mov ebp, eax

    mov eax, esi
    add eax, edi
    cmp eax, ebp
    jle not_possible

    mov eax, edi
    add eax, ebp
    cmp eax, esi
    jle not_possible

    mov eax, esi
    add eax, ebp
    cmp eax, edi
    jle not_possible

    mov eax, 4
    mov ebx, 1
    mov ecx, triangle_possible
    mov edx, 17
    int 0x80

    cmp esi, edi
    jne check_isosceles

    cmp esi, ebp
    jne check_isosceles

    mov eax, 4
    mov ebx, 1
    mov ecx, equilateral
    mov edx, 11
    int 0x80
    jmp done

check_isosceles:
    cmp esi, edi
    je isosceles_case
    cmp esi, ebp
    je isosceles_case
    cmp edi, ebp
    je isosceles_case

    mov eax, 4
    mov ebx, 1
    mov ecx, scalene
    mov edx, 8
    int 0x80
    jmp done

isosceles_case:
    mov eax, 4
    mov ebx, 1
    mov ecx, isosceles
    mov edx, 9
    int 0x80
    jmp done

not_possible:
    mov eax, 4
    mov ebx, 1
    mov ecx, triangle_not_possible
    mov edx, 20
    int 0x80

done:
    mov eax, 1
    mov ebx, 0
    int 0x80

convert_to_number:
    xor eax, eax
    xor ebx, ebx

parse_digit:
    movzx edx, byte [ecx]
    cmp dl, 0x0A 
    je done_conversion
    sub dl, '0'
    imul eax, eax, 10
    add eax, edx
    inc ecx
    jmp parse_digit

done_conversion:
    ret

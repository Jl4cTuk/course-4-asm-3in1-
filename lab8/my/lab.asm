section .data
    msg_palindrome db "palindrome", 0
    msg_not_palindrome db "not palindrome", 0
    newline db 0xA
    input_x db "enter x: ", 0

section .bss
    x resb 32
    n resd 1

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, input_x
    mov edx, 9
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, x
    mov edx, 32
    int 0x80

    call str_to_bool_vector

    mov esi, x
    mov eax, [n]
    mov ecx, eax
    call is_palindrome

    cmp eax, 1
    je palindrome_found
    jne not_palindrome_found

palindrome_found:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_palindrome
    mov edx, 10
    int 0x80
    jmp exit_program

not_palindrome_found:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_not_palindrome
    mov edx, 14
    int 0x80
    jmp exit_program

exit_program:
    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80

str_to_bool_vector:
    mov esi, x
    xor ecx, ecx

    .loop_bits:
        mov al, byte [esi]
        cmp al, 0xA
        je .done_bits
        cmp al, '1'
        je .set_bit
        cmp al, '0'
        je .set_zero
        jmp .invalid_symbol

    .set_bit:
        or byte [x + ecx], 1
        jmp .next_bit

    .set_zero:
        and byte [x + ecx], 0
        jmp .next_bit

    .invalid_symbol:
        mov eax, 1
        mov ebx, 1
        int 0x80

    .next_bit:
        inc esi
        inc ecx
        jmp .loop_bits

    .done_bits:
        mov [n], ecx
        ret

; esi - указатель на вектор
; ecx - длина
is_palindrome:
    push ebp
    mov ebp, esp
    mov ebx, 0
    mov edx, ecx
    dec edx

    .check_loop:
        cmp ebx, edx
        jge .is_palindrome

        mov al, byte [esi + ebx]
        mov ah, byte [esi + edx]
        cmp al, ah
        jne .not_palindrome_flag

        inc ebx
        dec edx
        jmp .check_loop

    .is_palindrome:
        mov eax, 1
        pop ebp
        ret

    .not_palindrome_flag:
        mov eax, 0
        pop ebp
        ret

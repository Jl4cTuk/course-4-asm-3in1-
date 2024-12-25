section .data
    ; Array A with 5 zeros
    A dd 0, 1, 1, -1, -1
    A_size equ ($ - A) / 4

    ; Messages for output
    msg_pos db "Положительных элементов больше.", 10
    len_pos equ $ - msg_pos

    msg_neg db "Отрицательных элементов больше.", 10
    len_neg equ $ - msg_neg

    msg_zero db "Нулей больше.", 10
    len_zero equ $ - msg_zero

    msg_equal db "Количество положительных, отрицательных и нулевых элементов одинаково.", 10
    len_equal equ $ - msg_equal

section .bss
    ; Counters
    pos_count resd 1
    neg_count resd 1
    zero_count resd 1

section .text
    global _start

_start:
    ; Initialize counters to 0
    mov dword [pos_count], 0
    mov dword [neg_count], 0
    mov dword [zero_count], 0

    ; Initialize pointer and loop counter
    mov esi, A
    mov ecx, A_size  ; Number of elements

count_loop:
    cmp ecx, 0
    je compare_counts

    ; Load current element
    mov eax, [esi]
    
    ; Check for zero
    cmp eax, 0
    je increment_zero

    ; Check for positive
    jg increment_pos

    ; Else, it's negative
    jmp increment_neg

increment_zero:
    ; Increment zero_count directly
    add dword [zero_count], 1
    jmp next_element

increment_pos:
    ; Increment pos_count directly
    add dword [pos_count], 1
    jmp next_element

increment_neg:
    ; Increment neg_count directly
    add dword [neg_count], 1
    jmp next_element

next_element:
    ; Move to next element
    add esi, 4
    dec ecx
    jmp count_loop

compare_counts:
    ; Load counters into registers
    mov eax, [pos_count]
    mov ebx, [neg_count]
    mov ecx, [zero_count]

    ; Compare positive and negative counts
    cmp eax, ebx
    jg greater_pos
    jl greater_neg
    je check_zero

greater_pos:
    ; Print positive message
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, msg_pos
    mov edx, len_pos
    int 0x80
    jmp exit_program

greater_neg:
    ; Print negative message
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, msg_neg
    mov edx, len_neg
    int 0x80
    jmp exit_program

check_zero:
    ; Compare zero_count with pos and neg counts
    cmp ecx, eax        ; zero_count vs pos_count
    jg greater_zero
    cmp ecx, ebx        ; zero_count vs neg_count
    jg greater_zero
    ; If zero_count is not greater, counts are equal
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_equal
    mov edx, len_equal
    int 0x80
    jmp exit_program

greater_zero:
    ; Print zero message
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, msg_zero
    mov edx, len_zero
    int 0x80
    jmp exit_program

exit_program:
    ; Exit the program
    mov eax, 1          ; sys_exit
    xor ebx, ebx        ; return code 0
    int 0x80

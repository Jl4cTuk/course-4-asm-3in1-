section .data

    ROWS equ 4
    COLS equ 6

    matrix dd 5, 12, 3, 9, 14, 2, 8, 7, 11, 1, 6, 4, 13, 16, 10, 15, 18, 20, 21, 17, 19, 22, 24, 23

    newline db 10      ; newline character
    space   db ' '     ; space character

section .bss

    buffer resb 12
    max_value resd 1
    max_i resd 1
    max_j resd 1

section .text
    global _start

_start:
    ; Initialize max_value, max_i, max_j
    mov esi, 0  ; i = 0
    mov edi, 0  ; j = 0

    ; Calculate offset for matrix[0][0]
    mov eax, esi
    imul eax, COLS
    add eax, edi
    shl eax, 2
    ; Load matrix[0][0] into ebx
    mov ebx, [matrix + eax]
    mov [max_value], ebx
    mov [max_i], esi
    mov [max_j], edi

    ; Loop over i
    mov esi, 0  ; i = 0

find_max_outer_loop:
    cmp esi, ROWS
    jge find_max_end_outer_loop

    mov edi, 0  ; j = 0

find_max_inner_loop:
    cmp edi, COLS
    jge find_max_end_inner_loop

    ; Calculate offset = (i * COLS + j) * 4
    mov eax, esi
    imul eax, COLS
    add eax, edi
    shl eax, 2
    ; eax now contains offset

    ; Load matrix[i][j] into ebx
    mov ebx, [matrix + eax]

    ; Compare with max_value
    mov ecx, [max_value]
    cmp ebx, ecx
    jle skip_update_max  ; If matrix[i][j] <= max_value, skip updating

    ; Update max_value, max_i, max_j
    mov [max_value], ebx
    mov [max_i], esi
    mov [max_j], edi

skip_update_max:
    inc edi
    jmp find_max_inner_loop

find_max_end_inner_loop:
    inc esi
    jmp find_max_outer_loop

find_max_end_outer_loop:

    ; Swap rows to bring max_i to row 0 by swapping adjacent rows
    mov eax, [max_i]  ; eax = max_i
    cmp eax, 0
    jle swap_rows_done

    push ebx
    push edi

swap_rows_loop:
    cmp eax, 0
    jle swap_rows_done_pop

    ; For j from 0 to COLS - 1
    mov esi, 0  ; esi = j

swap_adjacent_rows_inner_loop:
    cmp esi, COLS
    jge swap_adjacent_rows_inner_done

    ; Calculate offset for matrix[eax][j]
    mov edx, eax   ; edx = current max_i
    imul edx, COLS
    add edx, esi
    shl edx, 2  ; edx = offset for matrix[eax][j]

    ; Calculate offset for matrix[eax - 1][j]
    mov ecx, eax
    dec ecx  ; ecx = eax - 1
    imul ecx, COLS
    add ecx, esi
    shl ecx, 2  ; ecx = offset for matrix[eax - 1][j]

    ; Swap matrix[eax][j] and matrix[eax - 1][j]
    mov ebx, [matrix + edx]
    mov edi, [matrix + ecx]
    mov [matrix + edx], edi
    mov [matrix + ecx], ebx

    inc esi
    jmp swap_adjacent_rows_inner_loop

swap_adjacent_rows_inner_done:
    dec eax  ; eax = eax - 1
    jmp swap_rows_loop

swap_rows_done_pop:
    pop edi
    pop ebx

swap_rows_done:
    ; Now, max_i is at row 0
    mov dword [max_i], 0

    ; Swap columns to bring max_j to column 0 by swapping adjacent columns
    mov eax, [max_j]  ; eax = max_j
    cmp eax, 0
    jle swap_cols_done

    push ebx
    push edi

swap_cols_loop:
    cmp eax, 0
    jle swap_cols_done_pop

    ; For i from 0 to ROWS - 1
    mov esi, 0  ; esi = i

swap_adjacent_cols_inner_loop:
    cmp esi, ROWS
    jge swap_adjacent_cols_inner_done

    ; Calculate offset for matrix[i][eax]
    mov edx, esi   ; edx = i
    imul edx, COLS
    add edx, eax
    shl edx, 2  ; edx = offset for matrix[i][eax]

    ; Calculate offset for matrix[i][eax - 1]
    mov ecx, esi
    imul ecx, COLS
    mov ebx, eax
    dec ebx  ; ebx = eax - 1
    add ecx, ebx
    shl ecx, 2  ; ecx = offset for matrix[i][eax - 1]

    ; Swap matrix[i][eax] and matrix[i][eax - 1]
    mov ebx, [matrix + edx]
    mov edi, [matrix + ecx]
    mov [matrix + edx], edi
    mov [matrix + ecx], ebx

    inc esi
    jmp swap_adjacent_cols_inner_loop

swap_adjacent_cols_inner_done:
    dec eax
    jmp swap_cols_loop

swap_cols_done_pop:
    pop edi
    pop ebx

swap_cols_done:
    ; Now, max_j is at column 0
    mov dword [max_j], 0

    ; Output the resulting matrix
    mov esi, 0  ; i = 0

print_loop_i:
    cmp esi, ROWS
    jge print_end_loop_i

    mov edi, 0  ; j = 0

print_loop_j:
    cmp edi, COLS
    jge print_end_loop_j

    ; Calculate offset for matrix[i][j]
    mov eax, esi
    imul eax, COLS
    add eax, edi
    shl eax, 2
    ; eax = offset

    mov eax, [matrix + eax]

    ; Call print_num to print eax
    call print_num

    ; Print space
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

    inc edi
    jmp print_loop_j

print_end_loop_j:
    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    inc esi
    jmp print_loop_i

print_end_loop_i:
    ; Exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80

; Procedure to print number in eax
print_num:
    ; eax contains number to print
    push ebp
    push ebx
    push ecx
    push edx
    push esi

    mov esi, buffer + 11
    mov byte [esi], 0

    mov ebx, 10

    ; Check if eax is zero
    cmp eax, 0
    jne .print_num_loop
    dec esi
    mov byte [esi], '0'
    jmp .print_num_end

.print_num_loop:
    xor edx, edx
    div ebx
    dec esi
    add dl, '0'
    mov [esi], dl
    test eax, eax
    jnz .print_num_loop

.print_num_end:
    ; Print number
    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    mov edx, buffer + 11
    sub edx, esi
    int 0x80

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop ebp
    ret

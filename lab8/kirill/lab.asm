section .data
    n dd 10                
    msg_ascend db "a -> b", 0
    msg_ascend_2 db "b -> a", 0
    msg_not_comparable db "uncomparable", 0
    newline db 0xA
    input_a db "Enter vector a (1s and 0s only):", 0
    input_b db "Enter vector b (1s and 0s only):", 0

section .bss
    a resb 32              
    b resb 32              

section .text
    global _start

_start:
    mov eax, 4            
    mov ebx, 1             
    mov ecx, input_a
    mov edx, 32           
    int 0x80

    mov eax, 3            
    mov ebx, 0             
    mov ecx, a             
    mov edx, 32           
    int 0x80

    mov eax, 4            
    mov ebx, 1            
    mov ecx, input_b
    mov edx, 32          
    int 0x80

    mov eax, 3             
    mov ebx, 0             
    mov ecx, b            
    mov edx, 32          
    int 0x80

    call string_to_bool_vector
    
    mov esi, [a]         
    mov edi, [b]       
    mov ecx, [n]         
    call are_comparable

    cmp eax, 1          
    jne comparable       

    mov esi, [b]         
    mov edi, [a]         
    mov ecx, [n]         
    call are_comparable

    cmp eax, 1           
    jne comparable_2     

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_not_comparable
    mov edx, 12
    int 0x80
    jmp exit

comparable:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_ascend
    mov edx, 6
    int 0x80
    jmp exit

comparable_2:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_ascend_2
    mov edx, 6
    int 0x80
    jmp exit

exit:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80

string_to_bool_vector:
    mov esi, a
    xor ecx, ecx       
    .loop_a:
        mov al, byte [esi]    
        cmp al, 0xA            
        je .done_a
        cmp al, '1'
        je .set_bit_a
        cmp al, '0'
        je .set_zero_a
        jmp .next_a

    .set_bit_a:
        or byte [a + ecx], 1   
        jmp .next_a

    .set_zero_a:
        and byte [a + ecx], 0  

    .next_a:
        inc esi
        inc ecx
        jmp .loop_a

    .done_a:

        mov esi, b
        xor ecx, ecx           
    .loop_b:
        mov al, byte [esi]     
        cmp al, 0xA            
        je .done_b
        cmp al, '1'
        je .set_bit_b
        cmp al, '0'
        je .set_zero_b
        jmp .next_b

    .set_bit_b:
        or byte [b + ecx], 1   
        jmp .next_b

    .set_zero_b:
        and byte [b + ecx], 0  

    .next_b:
        inc esi
        inc ecx
        jmp .loop_b

    .done_b:
        ret


are_comparable:
    mov edx, 0    ;flag        

.check_bits:
    test esi, 1           
    jz .next_bit_a         ;если 0, переходим к следующему биту
    test edi, 1            
    jnz .next_bit_a        ;если b[i] == 1, продолжаем

    ; если a[i] == 1 и b[i] == 0, то они несравнимы
    mov edx, 1
    jmp .done_check_bits

.next_bit_a:
    shr esi, 1
    shr edi, 1
    loop .check_bits

.done_check_bits:
    mov eax, edx
    ret

section .data
    prompt_name      db "What is your name? "
    len_name_p       equ $ - prompt_name
    
    prompt_age       db "How old are you? "
    len_age_p        equ $ - prompt_age
    
    prompt_gender    db "What is your gender? (M/F): "
    len_gender_p     equ $ - prompt_gender
    
    msg_hello_prefix db "Hello "
    len_hello_pref   equ $ - msg_hello_prefix
    
    msg_age_prefix   db "You are "
    len_age_pref     equ $ - msg_age_prefix
    
    str_m            db "Hello", 0xA
    len_m            equ $ - str_m
    
    str_f            db "World", 0xA
    len_f            equ $ - str_f
    
    str_invalid      db "INVALID", 0xA
    len_invalid      equ $ - str_invalid

section .bss
    name_buf         resb 50
    age_buf          resb 10
    gender_buf       resb 5
    name_len         resd 1
    age_len          resd 1

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_name
    mov edx, len_name_p
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, name_buf
    mov edx, 50
    int 0x80
    mov [name_len], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_age
    mov edx, len_age_p
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, age_buf
    mov edx, 10
    int 0x80
    mov [age_len], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_gender
    mov edx, len_gender_p
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, gender_buf
    mov edx, 5
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_hello_prefix
    mov edx, len_hello_pref
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, name_buf
    mov edx, [name_len]
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_age_prefix
    mov edx, len_age_pref
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, age_buf
    mov edx, [age_len]
    int 0x80

    mov al, [gender_buf]

    cmp al, 'M'
    je print_m

    cmp al, 'm'
    je print_m

    cmp al, 'F'
    je print_f

    cmp al, 'f'
    je print_f

    jmp print_inv

print_m:
    mov eax, 4
    mov ebx, 1
    mov ecx, str_m
    mov edx, len_m
    int 0x80
    jmp exit_prog

print_f:
    mov eax, 4
    mov ebx, 1
    mov ecx, str_f
    mov edx, len_f
    int 0x80
    jmp exit_prog

print_inv:
    mov eax, 4
    mov ebx, 1
    mov ecx, str_invalid
    mov edx, len_invalid
    int 0x80

exit_prog:
    mov eax, 1
    xor ebx, ebx
    int 0x80
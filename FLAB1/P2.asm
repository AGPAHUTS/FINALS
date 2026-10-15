section .data
    prompt_name   db "What is your name? "
    len_pname     equ $-prompt_name
    prompt_age    db "How old are you? "
    len_page      equ $-prompt_age
    prompt_year   db "What is your year level? "
    len_pyear     equ $-prompt_year

    msg_hello     db "Hello "
    len_hello     equ $-msg_hello
    msg_age       db "You are "
    len_age_msg   equ $-msg_age
    msg_years_old db " years old", 0xA
    len_years_old equ $-msg_years_old

    str_freshman  db "Freshman", 0xA
    len_freshman  equ $-str_freshman
    str_sophomore db "Sophomore", 0xA
    len_sophomore equ $-str_sophomore
    str_junior    db "Junior", 0xA
    len_junior    equ $-str_junior
    str_senior    db "Senior", 0xA
    len_senior    equ $-str_senior
    str_invalid   db "INVALID YEAR LEVEL", 0xA
    len_invalid   equ $-str_invalid

section .bss
    name          resb 50
    name_len      resb 4
    age           resb 5
    year_level    resb 2

section .text
    global _start

_start:
    ; Ask for full name
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_name
    mov edx, len_pname
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, name
    mov edx, 50
    int 0x80
    mov [name_len], eax

    ; Ask for age
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_age
    mov edx, len_page
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, age
    mov edx, 5
    int 0x80

    ; Ask for year level
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_year
    mov edx, len_pyear
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, year_level
    mov edx, 2
    int 0x80

    ; Display "Hello <name>"
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_hello
    mov edx, len_hello
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, name
    mov edx, [name_len]
    int 0x80

    ; Display "You are <age> years old"
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_age
    mov edx, len_age_msg
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, age
    mov edx, 2
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_years_old
    mov edx, len_years_old
    int 0x80

    ; Multi-branch selection for year level
    mov al, [year_level]
    cmp al, '1'
    je print_freshman
    cmp al, '2'
    je print_sophomore
    cmp al, '3'
    je print_junior
    cmp al, '4'
    je print_senior
    jmp print_invalid

print_freshman:
    mov eax, 4
    mov ebx, 1
    mov ecx, str_freshman
    mov edx, len_freshman
    int 0x80
    jmp exit_prog

print_sophomore:
    mov eax, 4
    mov ebx, 1
    mov ecx, str_sophomore
    mov edx, len_sophomore
    int 0x80
    jmp exit_prog

print_junior:
    mov eax, 4
    mov ebx, 1
    mov ecx, str_junior
    mov edx, len_junior
    int 0x80
    jmp exit_prog

print_senior:
    mov eax, 4
    mov ebx, 1
    mov ecx, str_senior
    mov edx, len_senior
    int 0x80
    jmp exit_prog

print_invalid:
    mov eax, 4
    mov ebx, 1
    mov ecx, str_invalid
    mov edx, len_invalid
    int 0x80

exit_prog:
    mov eax, 1
    xor ebx, ebx
    int 0x80
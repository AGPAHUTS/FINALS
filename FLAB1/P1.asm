; 32-bit NASM Program for Problem 1: Name, Age, and Gender Greeting
; Incorporating concepts from Modules 1, 2, 3, and 4

section .data
    prompt_name      db "What is your name? "
    len_name_p       equ $ - prompt_name             ; Calculate string length using $ counter
    
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
    name_buf         resb 50                        ; Reserve 50 uninitialized bytes for name
    age_buf          resb 10                        ; Reserve 10 uninitialized bytes for age
    gender_buf       resb 5                         ; Reserve 5 uninitialized bytes for gender
    name_len         resd 1                         ; Reserve a doubleword for storing name length
    age_len          resd 1                         ; Reserve a doubleword for storing age length

section .text
    global _start                                   ; Must be declared for the linker

_start:
    ; 1. Display name prompt using sys_write
    mov eax, 4                                      ; System call number for sys_write
    mov ebx, 1                                      ; File descriptor 1 (stdout)
    mov ecx, prompt_name                            ; Message pointer
    mov edx, len_name_p                             ; Message length
    int 0x80                                        ; Call Linux kernel interrupt

    ; Read user's full name into buffer using sys_read
    mov eax, 3                                      ; System call number for sys_read
    mov ebx, 0                                      ; File descriptor 0 (stdin)
    mov ecx, name_buf                               ; Buffer address
    mov edx, 50                                     ; Maximum bytes to read
    int 0x80
    mov [name_len], eax                             ; Save actual bytes read

    ; 2. Display age prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_age
    mov edx, len_age_p
    int 0x80

    ; Read user's age
    mov eax, 3
    mov ebx, 0
    mov ecx, age_buf
    mov edx, 10
    int 0x80
    mov [age_len], eax

    ; 3. Display gender prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_gender
    mov edx, len_gender_p
    int 0x80

    ; Read user's gender
    mov eax, 3
    mov ebx, 0
    mov ecx, gender_buf
    mov edx, 5
    int 0x80

    ; 4. Print "Hello <name>"
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

    ; 5. Print "You are <age> years old"
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

    ; 6. Character comparisons and conditional logic for gender input
    mov al, [gender_buf]                            ; Load first character of gender input into AL register

    cmp al, 'M'                                     ; Compare character with 'M'
    je print_m                                      ; Jump if equal to label print_m

    cmp al, 'm'                                     ; Compare character with lowercase 'm'
    je print_m

    cmp al, 'F'                                     ; Compare character with 'F'
    je print_f

    cmp al, 'f'                                     ; Compare character with lowercase 'f'
    je print_f

    jmp print_inv                                   ; Unconditional jump to invalid handler if no matches found

print_m:
    mov eax, 4
    mov ebx, 1
    mov ecx, str_m
    mov edx, len_m
    int 0x80
    jmp exit_prog                                   ; Skip other branches using unconditional jump

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
    mov eax, 1                                      ; System call number for sys_exit
    xor ebx, ebx                                    ; Clear EBX register to return exit code 0
    int 0x80                                        ; Terminate program via kernel
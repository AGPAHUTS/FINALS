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
    ; --- Step 1: Prompt user for full name ---
    mov eax, 4              ; sys_write system call number
    mov ebx, 1              ; file descriptor 1 (stdout)[cite: 25]
    mov ecx, prompt_name    ; address of prompt string[cite: 25]
    mov edx, len_pname      ; length of prompt string[cite: 25]
    int 0x80                ; invoke Linux kernel API[cite: 23]

    ; Read user input for name into buffer
    mov eax, 3              ; sys_read system call number[cite: 26]
    mov ebx, 0              ; file descriptor 0 (stdin)
    mov ecx, name           ; destination buffer
    mov edx, 50             ; max bytes to read
    int 0x80                ; invoke Linux kernel API[cite: 23]
    mov [name_len], eax     ; store actual number of bytes read

    ; --- Step 2: Prompt user for age ---
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_age
    mov edx, len_page
    int 0x80

    ; Read age input
    mov eax, 3
    mov ebx, 0
    mov ecx, age
    mov edx, 5
    int 0x80

    ; --- Step 3: Prompt user for year level ---
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_year
    mov edx, len_pyear
    int 0x80

    ; Read year level input
    mov eax, 3
    mov ebx, 0
    mov ecx, year_level
    mov edx, 2
    int 0x80

    ; --- Step 4: Display greeting "Hello <name>" ---
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_hello
    mov edx, len_hello
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, name
    mov edx, [name_len]     ; use recorded input length
    int 0x80

    ; --- Step 5: Display age statement "You are <age> years old" ---
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

    ; --- Step 6: Multi-branch evaluation of year level ---
    mov al, [year_level]    ; move the entered character into AL register
    cmp al, '1'             ; compare input with ASCII '1'
    je print_freshman       | jump to freshman block if equal
    cmp al, '2'             ; compare with ASCII '2'[cite: 87]
    je print_sophomore      ; jump to sophomore block if equal[cite: 91]
    cmp al, '3'             ; compare with ASCII '3'[cite: 87]
    je print_junior         ; jump to junior block if equal[cite: 91]
    cmp al, '4'             ; compare with ASCII '4'[cite: 87]
    je print_senior         ; jump to senior block if equal[cite: 91]
    jmp print_invalid       ; otherwise, jump to invalid level handler

print_freshman:
    mov eax, 4
    mov ebx, 1
    mov ecx, str_freshman
    mov edx, len_freshman
    int 0x80
    jmp exit_prog           ; prevent fall-through by jumping to exit[cite: 86, 89]

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
    mov eax, 1              ; sys_exit system call number[cite: 25, 26]
    xor ebx, ebx            ; exit status code 0[cite: 80]
    int 0x80                ; terminate program via kernel[cite: 23]
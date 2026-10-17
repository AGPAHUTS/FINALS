section .data
    prompt_name  db "Enter student name: "
    len_name_p   equ $-prompt_name
    prompt_id    db "Enter student ID: "
    len_id_p     equ $-prompt_id
    prompt_grade db "Enter grade: "
    len_grade_p  equ $-prompt_grade
    
    out_name     db "Student Name: "
    len_out_n    equ $-out_name
    out_id       db "Student ID: "
    len_out_i    equ $-out_id
    out_grade    db "Grade: "
    len_out_g    equ $-out_grade
    out_class    db "Classification: "
    len_out_c    equ $-out_class
    
    c_exc        db "Excellent", 0xA
    len_exc      equ $-c_exc
    c_vgood      db "Very Good", 0xA
    len_vgood    equ $-c_vgood
    c_good       db "Good", 0xA
    len_good     equ $-c_good
    c_passed     db "Passed", 0xA
    len_passed   equ $-c_passed
    c_failed     db "Failed", 0xA
    len_failed   equ $-c_failed
    c_inv        db "INVALID GRADE", 0xA
    len_inv      equ $-c_inv

section .bss
    name_buf     resb 50
    id_buf       resb 20
    grade_buf    resb 10

section .text
    global _start

_start:
    ; 1. Ask and read student name using sys_write and sys_read
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

    ; 2. Ask and read student ID as text to preserve leading zeros
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_id
    mov edx, len_id_p
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, id_buf
    mov edx, 20
    int 0x80

    ; 3. Ask and read integer grade string from keyboard
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_grade
    mov edx, len_grade_p
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, grade_buf
    mov edx, 10
    int 0x80

    ; 4. Parse grade characters from ASCII string into binary numeric format
    movzx ecx, byte [grade_buf]
    sub ecx, '0'
    cmp ecx, 0
    jl invalid_grade
    cmp ecx, 9
    jg invalid_grade

    movzx edx, byte [grade_buf + 1]
    cmp edx, 0xA
    je single_digit
    cmp edx, 0xD
    je single_digit
    sub edx, '0'
    cmp edx, 0
    jl invalid_grade
    cmp edx, 9
    jg invalid_grade

    ; Two-digit conversion: multiply tens digit by 10 and add units digit
    mov eax, ecx
    mov ebx, 10
    mul bl
    movzx ecx, dl
    add eax, ecx

    movzx edx, byte [grade_buf + 2]
    cmp edx, 0xA
    je check_ranges
    cmp edx, 0xD
    je check_ranges
    sub edx, '0'
    cmp edx, 0
    jl invalid_grade
    cmp edx, 9
    jg invalid_grade

    ; Three-digit conversion (handles value 100)
    mov ecx, eax
    mov eax, ecx
    mov ebx, 10
    mul bl
    movzx ecx, dl
    add eax, ecx
    jmp check_ranges

single_digit:
    mov eax, ecx

check_ranges:
    ; Validate overall numeric boundaries (0 to 100)
    cmp eax, 0
    jl invalid_grade
    cmp eax, 100
    jg invalid_grade

    ; Compare ranges in descending order using conditional jumps
    cmp eax, 90
    jge cls_excellent
    cmp eax, 85
    jge cls_vgood
    cmp eax, 80
    jge cls_good
    cmp eax, 75
    jge cls_passed
    jmp cls_failed

cls_excellent:
    mov ecx, c_exc
    mov edx, len_exc
    jmp display_result

cls_vgood:
    mov ecx, c_vgood
    mov edx, len_vgood
    jmp display_result

cls_good:
    mov ecx, c_good
    mov edx, len_good
    jmp display_result

cls_passed:
    mov ecx, c_passed
    mov edx, len_passed
    jmp display_result

cls_failed:
    mov ecx, c_failed
    mov edx, len_failed
    jmp display_result

invalid_grade:
    ; Handle out-of-range or non-numeric entries
    mov ecx, c_inv
    mov edx, len_inv

display_result:
    push ecx
    push edx

    ; Output formatted Student Name label and string buffer
    mov eax, 4
    mov ebx, 1
    mov ecx, out_name
    mov edx, len_out_n
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, name_buf
    mov edx, 50
    int 0x80

    ; Output formatted Student ID label and string buffer
    mov eax, 4
    mov ebx, 1
    mov ecx, out_id
    mov edx, len_out_i
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, id_buf
    mov edx, 20
    int 0x80

    ; Output formatted Grade label and string buffer
    mov eax, 4
    mov ebx, 1
    mov ecx, out_grade
    mov edx, len_out_g
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, grade_buf
    mov edx, 10
    int 0x80

    ; Output formatted Classification label and matched result string
    mov eax, 4
    mov ebx, 1
    mov ecx, out_class
    mov edx, len_out_c
    int 0x80

    pop edx
    pop ecx
    mov eax, 4
    mov ebx, 1
    int 0x80

    ; Terminate program execution safely via sys_exit
    mov eax, 1
    xor ebx, ebx
    int 0x80
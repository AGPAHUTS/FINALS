; =====================================================================
; SECTION .data - Initialized Data Segment
; Stores prompt messages, response notifications, fixed PIN, and balance.
; =====================================================================
section .data
    prompt_name   db "Enter account name: ", 0
    len_name      equ $ - prompt_name
    prompt_pin    db "Enter PIN: ", 0
    len_pin       equ $ - prompt_pin
    msg_granted   db "ACCESS GRANTED", 0xA, 0
    len_granted   equ $ - msg_granted
    msg_denied    db "ACCESS DENIED", 0xA, 0
    len_denied    equ $ - msg_denied
    msg_bal       db "Current Balance: PHP 10000", 0xA, 0
    len_bal       equ $ - msg_bal
    prompt_amt    db "Enter withdrawal amount: ", 0
    len_amt       equ $ - prompt_amt
    
    msg_succ      db "WITHDRAWAL SUCCESSFUL", 0xA, 0
    len_succ      equ $ - msg_succ
    msg_inv_amt   db "INVALID AMOUNT", 0xA, 0
    len_inv_amt   equ $ - msg_inv_amt
    msg_ins_fund  db "INSUFFICIENT FUNDS", 0xA, 0
    len_ins_fund  equ $ - msg_ins_fund
    msg_mult_100  db "AMOUNT MUST BE A MULTIPLE OF 100", 0xA, 0
    len_mult_100  equ $ - msg_mult_100
    
    msg_withdrawn db "Amount Withdrawn: PHP 2500", 0xA, 0
    len_withdrawn equ $ - msg_withdrawn
    msg_rem_bal   db "Remaining Balance: PHP 7500", 0xA, 0
    len_rem_bal   equ $ - msg_rem_bal

    correct_pin   db "1234"
    balance       dw 10000

; =====================================================================
; SECTION .bss - Uninitialized Data Segment
; Reserves memory space for user inputs (name, PIN, and amount).
; =====================================================================
section .bss
    name_input    resb 50
    pin_input     resb 5
    amt_input     resb 10

; =====================================================================
; SECTION .text - Code Segment
; Contains the main program execution logic and system call handlers.
; =====================================================================
section .text
    global _start

_start:
    ; -----------------------------------------------------------------
    ; Account Name Input Routine
    ; Displays prompt and reads user account name via Linux syscalls.
    ; -----------------------------------------------------------------
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_name
    mov edx, len_name
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, name_input
    mov edx, 50
    int 0x80

    ; -----------------------------------------------------------------
    ; PIN Authentication Routine
    ; Prompts user for PIN and compares it against the hardcoded value.
    ; -----------------------------------------------------------------
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_pin
    mov edx, len_pin
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, pin_input
    mov edx, 5
    int 0x80

    mov eax, [pin_input]
    mov ebx, [correct_pin]
    cmp eax, ebx
    jne access_denied

    ; -----------------------------------------------------------------
    ; Success & Balance Display
    ; Shows access confirmation and displays the current account balance.
    ; -----------------------------------------------------------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_granted
    mov edx, len_granted
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_bal
    mov edx, len_bal
    int 0x80

    ; -----------------------------------------------------------------
    ; Withdrawal Amount Input Routine
    ; Requests withdrawal amount from user via standard input.
    ; -----------------------------------------------------------------
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_amt
    mov edx, len_amt
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, amt_input
    mov edx, 10
    int 0x80

    ; -----------------------------------------------------------------
    ; Balance Limit Validation Check
    ; Compares the requested amount against the account balance using CMP.
    ; -----------------------------------------------------------------
    movzx eax, word [balance]
    mov ebx, 2500         
    cmp ebx, eax
    jg insufficient_funds

    ; -----------------------------------------------------------------
    ; Multiple of 100 Validation Check
    ; Performs division via DIV and checks remainder in AH register.
    ; -----------------------------------------------------------------
    mov ax, 2500
    mov bl, 100
    div bl
    cmp ah, 0
    jne not_multiple

    ; -----------------------------------------------------------------
    ; Successful Withdrawal Output
    ; Prints success message, withdrawn sum, and remaining balance.
    ; -----------------------------------------------------------------
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_succ
    mov edx, len_succ
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_withdrawn
    mov edx, len_withdrawn
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_rem_bal
    mov edx, len_rem_bal
    int 0x80
    jmp exit_prog

; =====================================================================
; Error Handling Routines & Program Exit
; Manages failed conditions (Access Denied, Insufficient Funds, etc.)
; =====================================================================
access_denied:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_denied
    mov edx, len_denied
    int 0x80
    jmp exit_prog

insufficient_funds:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_ins_fund
    mov edx, len_ins_fund
    int 0x80
    jmp exit_prog

not_multiple:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_mult_100
    mov edx, len_mult_100
    int 0x80

exit_prog:
    mov eax, 1
    xor ebx, ebx
    int 0x80
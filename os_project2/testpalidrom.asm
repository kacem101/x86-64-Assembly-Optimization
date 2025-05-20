
SECTION .data
    test_msg_madam  db "Testing 'madam': Expected 1 (Palindrome). Got: ", 0
    test_msg_hello  db "Testing 'hello': Expected 0 (Not Palindrome). Got: ", 0
    test_msg_racecar db "Testing 'racecar': Expected 1 (Palindrome). Got: ", 0
    test_msg_a      db "Testing 'a': Expected 1 (Palindrome). Got: ", 0
    test_msg_empty  db "Testing '': Expected 1 (Palindrome). Got: ", 0
    test_msg_ab     db "Testing 'ab': Expected 0 (Not Palindrome). Got: ", 0

    str_madam       db "madam", 0
    str_hello       db "hello", 0
    str_racecar     db "racecar", 0
    str_a           db "a", 0
    str_empty       db "", 0
    str_ab          db "ab", 0

    newline         db 0xA, 0

SECTION .bss
    resu_buf        resb 21 ; Buffer for print_number

SECTION .text
    global _start

; --- Function to be tested: isPalindrom ---
isPalindrom:
    mov     rsi, rdi          ; rsi = end_ptr, rdi = start_ptr
.find_endPalindrom:
    mov     al, [rsi]         ; load byte
    test    al, al            ; check for NUL
    jz      .got_endPalindrom
    inc     rsi               ; advance forward
    jmp     .find_endPalindrom
.got_endPalindrom:
    cmp     rdi, rsi          ; if rdi == rsi (e.g. empty string)
    je      .is_palindrome_true
    dec     rsi               ; back up to last character
.loop_cmpPalindrom:
    cmp     rdi, rsi
    jge     .is_palindrome_true
    mov     al, [rdi]
    mov     bl, [rsi]
    cmp     al, bl
    jne     .not_palindrome_false
    inc     rdi
    dec     rsi
    jmp     .loop_cmpPalindrom
.not_palindrome_false:
    mov     rax, 0
    jmp     .finpal
.is_palindrome_true:
    mov     rax, 1
.finpal:
    ret

; --- Helper print_string ---
print_string:
    push rax; push rdi; push rsi; push rdx
    mov r9, rdi ; Save original string pointer (RDI is arg1)
    mov rdx, 0  ; Length counter
.count_loop_ps:
    cmp byte [r9 + rdx], 0
    je .counted_ps
    inc rdx
    jmp .count_loop_ps
.counted_ps:
    mov rax, 1
    mov rdi, 1      ; stdout
    mov rsi, r9     ; buffer
    syscall
    pop rdx; pop rsi; pop rdi; pop rax
    ret

; --- Helper print_newline ---
print_newline:
    push rdi
    mov rdi, newline
    call print_string
    pop rdi
    ret

; --- Helper print_number (needed to print result of isPalindrom) ---
print_number:
    push rbx; push rcx; push rdx; push rdi; push rsi
    lea rdi, [resu_buf]
    mov rsi, rdi
    mov rbx, 10
    xor rcx, rcx
    cmp rax, 0
    jne .mloop_pn_isp
    mov byte [rdi], '0'
    inc rdi
    inc rcx
    jmp .printf_pn_isp
.mloop_pn_isp:
    xor rdx, rdx
    div rbx
    add dl, '0'
    push rdx
    inc rcx
    test rax, rax
    jnz .mloop_pn_isp
.inverser_pn_isp:
    pop rax
    mov [rdi], al
    inc rdi
    loop .inverser_pn_isp
.printf_pn_isp:
    mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    syscall
    pop rsi; pop rdi; pop rdx; pop rcx; pop rbx
    ret

_start:
    ; Test "madam"
    mov rdi, test_msg_madam
    call print_string
    mov rdi, str_madam
    call isPalindrom
    call print_number
    call print_newline

    ; Test "hello"
    mov rdi, test_msg_hello
    call print_string
    mov rdi, str_hello
    call isPalindrom
    call print_number
    call print_newline

    ; Test "racecar"
    mov rdi, test_msg_racecar
    call print_string
    mov rdi, str_racecar
    call isPalindrom
    call print_number
    call print_newline

    ; Test "a"
    mov rdi, test_msg_a
    call print_string
    mov rdi, str_a
    call isPalindrom
    call print_number
    call print_newline

    ; Test "" (empty string)
    mov rdi, test_msg_empty
    call print_string
    mov rdi, str_empty
    call isPalindrom
    call print_number
    call print_newline

    ; Test "ab"
    mov rdi, test_msg_ab
    call print_string
    mov rdi, str_ab
    call isPalindrom
    call print_number
    call print_newline

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

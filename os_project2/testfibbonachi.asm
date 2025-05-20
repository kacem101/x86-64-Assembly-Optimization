
SECTION .data
    msg_n0      db "Fib(0): Expected 0. Got: ", 0
    msg_n1      db "Fib(1): Expected 1. Got: ", 0
    msg_n2      db "Fib(2): Expected 1. Got: ", 0
    msg_n10     db "Fib(10): Expected 55. Got: ", 0
    msg_n20     db "Fib(20): Expected 6765. Got: ", 0

    newline     db 0xA, 0

SECTION .bss
    resu_buf    resb 21 ; Buffer for print_number

SECTION .text
    global _start

; --- Function to be tested: asm_fibonachi ---
asm_fibonachi:
    push rbx; push r12; push r13
    MOV R13, RDI ; n
    CMP R13, 0
    JE  .fib_is_zero_fib
    CMP R13, 1
    JE  .fib_is_one_fib
    MOV R8, 0
    MOV R12, 0 ; F(k-2)
    MOV R11, 1 ; F(k-1)
.forfib_user_fib:
    INC R8
    CMP R8, R13
    JGE .endfib_user_fib
    MOV R10, 0 ; temp sum
    ADD R10, R11
    ADD R10, R12
    MOV R12, R11
    MOV R11, R10
    MOV RAX, R10 ; Current F(R8+1) if R8 from 0, or F(R8) if R8 is "current N"
                 ; With user's loop structure, RAX gets F(n)
    JMP .forfib_user_fib
.endfib_user_fib:
    ; RAX should hold the last computed F(n) from the loop
    JMP .fib_finish_fib
.fib_is_zero_fib:
    MOV RAX, 0
    JMP .fib_finish_fib
.fib_is_one_fib:
    MOV RAX, 1
.fib_finish_fib:
    pop r13; pop r12; pop rbx
    RET

; --- Helper print_string ---
print_string:
    push rax; push rdi; push rsi; push rdx
    mov r9, rdi
    mov rdx, 0
.count_loop_ps_fib: cmp byte [r9 + rdx], 0; je .counted_ps_fib; inc rdx; jmp .count_loop_ps_fib
.counted_ps_fib: mov rax, 1; mov rdi, 1; mov rsi, r9; syscall
    pop rdx; pop rsi; pop rdi; pop rax; ret

; --- Helper print_newline ---
print_newline:
    push rdi; mov rdi, newline; call print_string; pop rdi; ret

; --- Helper print_number ---
print_number:
    push rbx; push rcx; push rdx; push rdi; push rsi
    lea rdi, [resu_buf]; mov rsi, rdi; mov rbx, 10; xor rcx, rcx
    cmp rax, 0; jne .mloop_pn_fib
    mov byte [rdi], '0'; inc rdi; inc rcx; jmp .printf_pn_fib
.mloop_pn_fib: xor rdx, rdx; div rbx; add dl, '0'; push rdx; inc rcx; test rax, rax; jnz .mloop_pn_fib
.inverser_pn_fib: pop rax; mov [rdi], al; inc rdi; loop .inverser_pn_fib
.printf_pn_fib: mov rax, 1; mov rdi, 1; mov rdx, rcx; syscall
    pop rsi; pop rdi; pop rdx; pop rcx; pop rbx; ret

_start:
    ; Test Fib(0)
    mov rdi, msg_n0
    call print_string
    mov rdi, 0          ; N = 0
    call asm_fibonachi  ; RAX = Fib(0)
    call print_number
    call print_newline

    ; Test Fib(1)
    mov rdi, msg_n1
    call print_string
    mov rdi, 1          ; N = 1
    call asm_fibonachi  ; RAX = Fib(1)
    call print_number
    call print_newline

    ; Test Fib(2)
    mov rdi, msg_n2
    call print_string
    mov rdi, 2          ; N = 2
    call asm_fibonachi  ; RAX = Fib(2)
    call print_number
    call print_newline

    ; Test Fib(10)
    mov rdi, msg_n10
    call print_string
    mov rdi, 10         ; N = 10
    call asm_fibonachi  ; RAX = Fib(10)
    call print_number
    call print_newline

    ; Test Fib(20)
    mov rdi, msg_n20
    call print_string
    mov rdi, 20         ; N = 20
    call asm_fibonachi  ; RAX = Fib(20)
    call print_number
    call print_newline

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

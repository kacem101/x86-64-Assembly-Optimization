
SECTION .data
    msg_original    db "Original Array: ", 0
    msg_sorted      db "Sorted Array:   ", 0
    space           db " ", 0
    newline         db 0xA, 0

    array1          dq 5, 1, 4, 2, 8
    array1_len      equ ($ - array1) / 8
    msg_array1      db "Test Case 1 (5, 1, 4, 2, 8):", 0

    array2          dq 9, 7, 5, 3, 1
    array2_len      equ ($ - array2) / 8
    msg_array2      db "Test Case 2 (9, 7, 5, 3, 1 - Reverse):", 0

    array3          dq 1, 2, 3, 4, 5
    array3_len      equ ($ - array3) / 8
    msg_array3      db "Test Case 3 (1, 2, 3, 4, 5 - Sorted):", 0

    array4          dq 42
    array4_len      equ ($ - array4) / 8
    msg_array4      db "Test Case 4 (42 - Single Element):", 0

    array5          dq 0 ; Placeholder for empty array logic
    array5_len      equ 0
    msg_array5      db "Test Case 5 (Empty Array):", 0


SECTION .bss
    resu_buf        resb 21 ; Buffer for print_number

SECTION .text
    global _start

; --- Function to be tested: asm_sort_array ---
asm_sort_array:
    push rbx; push r12; push r13; push r14
    MOV RCX, RDI
    MOV RDX, RSI
    CMP RDX, 1
    JLE .end_outer_loop_sort
    MOV R14, RDX ; Not strictly needed for current logic but was in original
    DEC RDX
    MOV R8, 0
.outer_loop_sort:
    CMP R8, RDX
    JGE .end_outer_loop_sort
    MOV R9, 0
    MOV R11, RDX
    SUB R11, R8
.inner_loop_sort:
    CMP R9, R11
    JGE .end_inner_loop_sort
    MOV R12, [RCX + R9*8]
    MOV R13, [RCX + R9*8 + 8]
    CMP R12, R13
    JLE .continue_inner_sort
.swap_sort:
    MOV [RCX + R9*8], R13
    MOV [RCX + R9*8 + 8], R12
.continue_inner_sort:
    INC R9
    JMP .inner_loop_sort
.end_inner_loop_sort:
    INC R8
    JMP .outer_loop_sort
.end_outer_loop_sort:
    pop r14; pop r13; pop r12; pop rbx
    RET

; --- Helper print_string ---
print_string:
    push rax; push rdi; push rsi; push rdx
    mov r9, rdi
    mov rdx, 0
.count_loop_ps_arr: cmp byte [r9 + rdx], 0; je .counted_ps_arr; inc rdx; jmp .count_loop_ps_arr
.counted_ps_arr: mov rax, 1; mov rdi, 1; mov rsi, r9; syscall
    pop rdx; pop rsi; pop rdi; pop rax; ret

; --- Helper print_newline ---
print_newline:
    push rdi; mov rdi, newline; call print_string; pop rdi; ret

; --- Helper print_number ---
print_number:
    push rbx; push rcx; push rdx; push rdi; push rsi
    lea rdi, [resu_buf]; mov rsi, rdi; mov rbx, 10; xor rcx, rcx
    cmp rax, 0; jne .mloop_pn_arr
    mov byte [rdi], '0'; inc rdi; inc rcx; jmp .printf_pn_arr
.mloop_pn_arr: xor rdx, rdx; div rbx; add dl, '0'; push rdx; inc rcx; test rax, rax; jnz .mloop_pn_arr
.inverser_pn_arr: pop rax; mov [rdi], al; inc rdi; loop .inverser_pn_arr
.printf_pn_arr: mov rax, 1; mov rdi, 1; mov rdx, rcx; syscall
    pop rsi; pop rdi; pop rdx; pop rcx; pop rbx; ret

; --- Helper print_array ---
; Input: rdi = array pointer, rsi = number of elements
print_array:
    push rax; push rdi; push rsi; push rcx; push rdx
    push r8; push r9;

    mov r8, rdi     ; array pointer
    mov r9, rsi     ; count
    xor rcx, rcx    ; loop counter i = 0

.loop_parr:
    cmp rcx, r9
    jge .end_parr

    mov rax, [r8 + rcx*8] ; Get array[i]
    call print_number

    ; Print space if not the last element
    push rax ; save rax from print_number (if it returns something, though it doesn't)
    mov rax, r9 ; current count
    dec rax     ; count - 1
    cmp rcx, rax
    pop rax   ; restore rax
    je .no_space_parr

    push rdi ; Save rdi before calling print_string with space
    mov rdi, space
    call print_string
    pop rdi

.no_space_parr:
    inc rcx
    jmp .loop_parr

.end_parr:
    pop r9; pop r8
    pop rdx; pop rcx; pop rsi; pop rdi; pop rax
    ret

_start:
    ; Test Case 1
    mov rdi, msg_array1; call print_string; call print_newline
    mov rdi, msg_original; call print_string
    mov rdi, array1; mov rsi, array1_len; call print_array; call print_newline
    mov rdi, array1; mov rsi, array1_len; call asm_sort_array
    mov rdi, msg_sorted; call print_string
    mov rdi, array1; mov rsi, array1_len; call print_array; call print_newline; call print_newline

    ; Test Case 2
    mov rdi, msg_array2; call print_string; call print_newline
    mov rdi, msg_original; call print_string
    mov rdi, array2; mov rsi, array2_len; call print_array; call print_newline
    mov rdi, array2; mov rsi, array2_len; call asm_sort_array
    mov rdi, msg_sorted; call print_string
    mov rdi, array2; mov rsi, array2_len; call print_array; call print_newline; call print_newline

    ; Test Case 3
    mov rdi, msg_array3; call print_string; call print_newline
    mov rdi, msg_original; call print_string
    mov rdi, array3; mov rsi, array3_len; call print_array; call print_newline
    mov rdi, array3; mov rsi, array3_len; call asm_sort_array
    mov rdi, msg_sorted; call print_string
    mov rdi, array3; mov rsi, array3_len; call print_array; call print_newline; call print_newline

    ; Test Case 4
    mov rdi, msg_array4; call print_string; call print_newline
    mov rdi, msg_original; call print_string
    mov rdi, array4; mov rsi, array4_len; call print_array; call print_newline
    mov rdi, array4; mov rsi, array4_len; call asm_sort_array
    mov rdi, msg_sorted; call print_string
    mov rdi, array4; mov rsi, array4_len; call print_array; call print_newline; call print_newline

    ; Test Case 5 (Empty array)
    mov rdi, msg_array5; call print_string; call print_newline
    mov rdi, msg_original; call print_string
    mov rdi, array5 ; address is valid, but len is 0
    mov rsi, array5_len ; rsi = 0
    call print_array    ; should print nothing or just newline if print_array handles 0 len
    call print_newline
    mov rdi, array5
    mov rsi, array5_len
    call asm_sort_array ; should handle 0 length gracefully
    mov rdi, msg_sorted; call print_string
    mov rdi, array5
    mov rsi, array5_len
    call print_array
    call print_newline; call print_newline

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

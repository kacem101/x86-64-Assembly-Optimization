section .data
    hello:              db 'Hello, World!',10    ; 'Hello, World!' plus a linefeed character
    helloLen:           equ $-hello             ; Length of the 'Hello world!' string
    newline_char:       db 10                   ; Newline character
    newline_charLen:    equ $-newline_char      ; Length of newline character
    space_char:         db ' '                  ; Space character for separating numbers
    space_charLen:      equ $-space_char        ; Length of space character

section .bss
	resu resb 20


section .text           ; Code section
global asm_function     ; Make this function's label visible to the linker
global asm_sort_array
global asm_reverse_array
global asm_reversewithstack_array
global asm_find_min_in_array
global asm_find_max_in_array
global asm_fibonachi
global print_number
global toUpperCase
global toLowerCase
global isPalindrom
global stringConcat
global reversString
global sumDiv
global isPerfect
global isSorted
global strgCopy
global linearSrch

isSorted:
     cmp rsi, 1
    jle .is_sorted_exit   ; If size <= 1, jump to .is_sorted_exit (return true)

    xor rcx, rcx

.loop_start:
    mov r8, rsi           ; Copy size to R8
    sub r8, 1             ; R8 = size - 1 (This is the maximum index we need to check, i.e., arr[size-2] vs arr[size-1])
    cmp rcx, r8           ; Compare i (RCX) with (size - 1)
    jge .is_sorted_exit   ; If i >= size - 1, we've checked all necessary pairs, array is sorted
    mov rax, rcx          ; Copy index i to RAX
    imul rax, 8           ; Multiply i by 8 to get byte offset
    add rax, rdi          ; Add offset to base address of array (arr + offset)
    mov r9, [rax]
    add rax, 8            ; Just add 8 bytes to RAX to get address of arr[i+1]
    mov r10, [rax]        ; arr[i+1]

    ; Compare arr[i] with arr[i+1]
    cmp r9, r10           ; Compare arr[i] with arr[i+1]
    jg .not_sorted_exit   ; If arr[i] > arr[i+1], it's not sorted (jump to return false)

    ; Increment loop counter
    inc rcx               ; i++
    jmp .loop_start

.is_sorted_exit:
    mov rax, 1
    ret

.not_sorted_exit:
    xor rax, rax
    ret
linearSrch:
    cmp rsi, 0
    jle .not_found_exit ; If size is 0 or less, element cannot be found

    xor rcx, rcx 

.loop_start:
    cmp rcx, rsi
    jge .not_found_exit ; If i >= size, we've checked all elements

    mov rax, rcx          ; Copy index i to RAX
    imul rax, 8           ; Multiply i by 8 to get byte offset
    add rax, rdi          ; Add offset to base address of array (arr + offset)
    mov r8, [rax]         ; Load arr[i] into R8
    cmp r8, rdx           ; Compare arr[i] with n
    je .found_exit        ; If they are equal, we found it
    inc rcx               ; i++
    jmp .loop_start       ; Continue loop

.found_exit:
    mov rax, 1            ; Set return value to true (1)
    ret

.not_found_exit:
    xor rax, rax          ; Set return value to false (0)
    ret

strgCopy:
.loop_copy:
    mov al, [rsi]       ; Load byte from source (src) into AL
    mov [rdi], al       ; Store byte from AL into destination (dest)

    cmp al, 0           ; Check if the copied byte is the null terminator
    je .end_copy        ; If it's the null terminator, we're done

    inc rdi             ; Increment destination pointer
    inc rsi             ; Increment source pointer
    jmp .loop_copy      ; Continue copying

.end_copy:
    ret                 ; Return from the function


isPerfect:
    push    rax
    call    sumDiv
    pop     rax
    sub     rbx, rax
    cmp     rbx, 0
    jne     notPerfect

    mov     rax, 1
    ret

notPerfect:
    xor     rax, rax
    ret

sumDiv:
    cmp     rdi, 0
    jle     zero

    xor     rbx, rbx
    mov     rax, 1

loopSD:
    cmp     rax, rdi
    ja      endSD

    mov     rdx, 0
    mov     rcx, rax
    mov     rax, rdi
    div     rcx

    cmp     rdx, 0
    jnz     skip_add

    add     rbx, rcx

skip_add:
    inc     rcx
    mov     rax, rcx
    jmp     loopSD

endSD:
    mov     rax, rbx
    ret

zero:
    xor     rax, rax

reversString:
    mov     rcx, rdi            ; rcx = x (iterator)
.find_endrev:
    mov     al, [rcx]           ; load *rcx
    test    al, al              ; check for NULL
    jz      .got_endrev            ; if zero, found terminator
    inc     rcx                  ; rcx++
    jmp     .find_endrev

.got_endrev:
    dec     rcx                  ; rcx-- to point at last char

    ; Now rcx = end pointer, rdi = start pointer
.swap_looprev:
    cmp     rdi, rcx             ; have pointers crossed?
    jge     .donerev                ; if rdi ≥ rcx, done

    
    mov     dl, [rcx]            ; dl = *end
    mov     al, [rdi]            ; al = *start
    mov     [rdi], dl            ; *start = old_end
    mov     [rcx], al            ; *end   = old_start

 
    inc     rdi                  ; start++
    dec     rcx                  ; end--
    jmp     .swap_looprev
.donerev:
    ret

stringConcat:
  
.find_endstrconcat:
    mov     dl, [rdi]        ; load byte at dest into DL
    test    dl, dl           ; is it '\0'?
    jz      .copy_strconcat        ; if yes, dest end found
    inc     rdi              ; advance dest pointer
    jmp     .find_endstrconcat

.copy_strconcat:
    mov     al, [rsi]        ; load byte at src into AL
    test    al, al           ; is it '\0'?
    jz      .write_null      ; if yes, end of src
    mov     [rdi], al        ; store byte to dest
    inc     rdi              ; dest++
    inc     rsi              ; src++
    jmp     .copy_strconcat

.write_null:
    mov     byte [rdi], 0    ; write final NULL terminator
    ret

isPalindrom:
    mov     rsi, rdi           
    
.find_endPalindrom:
    mov     al, [rsi]           ; load byte at [rsi]
    test    al, al              ; check for NUL
    jz      .got_endPalindrom
    inc     rsi                  ; advance forward
    jmp     .find_endPalindrom

.got_endPalindrom:
    dec     rsi                  ; back up to last character

.loop_cmpPalindrom:
    cmp     rdi, rsi             ; have pointers crossed?
    jge     .is_palindrome       ; if start >= end, it’s a palindrome

    mov     al, [rdi]            ; load *start
    mov     bl, [rsi]            ; load *end
    cmp     al, bl               ; compare characters
    jne     .not_palindrome      ; mismatch → false

    inc     rdi                  ; start++
    dec     rsi                  ; end--
    jmp     .loop_cmpPalindrom            ; repeat

.not_palindrome:
    mov     rax, 0              ; return false
    jmp     .finpal    
.is_palindrome:
    mov     rax, 1           ; return true
    jmp     .finpal
.finpal:
    ret
    
print_number:

displ:
mov rdi, resu; pointer results
mov rbx, 10
xor rcx, rcx         
test rax, rax
jnz .mloop
mov byte [rdi], '0'
inc rdi
inc rcx
jmp .printf
.mloop:
xor rdx, rdx        
div rbx              
add dl, '0'         
push rdx             
inc rcx              
test rax, rax        
jnz .mloop
.inverser:; parce que le push donne un nombre dans un ordre inverser donc on doivent le re-inverser 
pop rax             
mov [rdi], al   
inc rdi
loop .inverser
.printf:
inc rcx
mov rax, 1          
mov rdi, 1          
mov rsi, resu      
mov rdx, rcx         
syscall
ret

asm_function:
    MOV RCX,RDI
    MOV RAX, 1
    CMP RCX, 0
    JE .done_factorial

.for_factorial:
    MUL RCX
    DEC RCX
    CMP RCX, 0
    JNE .for_factorial

.done_factorial:
    RET

asm_sort_array:
    ; Input: RCX (long long* array_ptr), RDX (long long size)
    ; Implements bubble sort (Keeping your original bubble sort logic)
    MOV RCX,RDI
    MOV RDX,RSI
    MOV R10, RDX        ; Save original size N
    DEC RDX             ; RDX = N-1 for outer loop bound (index up to N-2)
    MOV R8, 0           ; R8 = outer loop counter i

.outer_loop:
    CMP R8, RDX         ; Compare i with N-1
    JGE .end_outer_loop ; If i >= N-1, done

    MOV R9, 0           ; R9 = inner loop counter j
    MOV R11, RDX        ; R11 = N-1
    SUB R11, R8         ; R11 = N-1-i (last possible index for j)

.inner_loop:
    CMP R9, R11         ; Compare j with R11, done
    JGE .end_inner_loop

    MOV R12, [RCX + R9*8]   ; R12 = array[j]
    MOV R13, [RCX + R9*8 + 8]; R13 = array[j+1]

    CMP R12, R13        ; Compare array[j] and array[j+1]
    JLE .continue_inner ; If array[j] <= array[j+1], no swap needed

.swap:
    MOV [RCX + R9*8], R13   ; array[j] = array[j+1]
    MOV [RCX + R9*8 + 8], R12 ; array[j+1] = array[j] (original R12)

.continue_inner:
    INC R9              ; Increment j
    JMP .inner_loop

.end_inner_loop:
    INC R8              ; Increment i
    JMP .outer_loop

.end_outer_loop:
    RET

asm_reverse_array:
    ; Input: RCX (long long* array_ptr), RDX (long long size)
    ; Reverses the array in-place (Keeping your original logic)
    MOV RCX,RDI
    MOV RDX,RSI

    MOV R8, 0           ; Left index (i)
    MOV R9, RDX         ; Right index (j)
    DEC R9              ; j = size - 1

.loop_reverse:
    CMP R8, R9          ; While left < right
    JGE .end_loop_reverse ; If left >= right, done

    MOV R10, [RCX + R8*8] ; Save array[i]
    MOV R11, [RCX + R9*8] ; Save array[j]

    MOV [RCX + R8*8], R11 ; array[i] = array[j]
    MOV [RCX + R9*8], R10 ; array[j] = array[i] (original value)

    INC R8              ; Increment left index
    DEC R9              ; Decrement right index
    JMP .loop_reverse

.end_loop_reverse:
    RET

asm_reversewithstack_array:
    ; Input: RCX (long long* array_ptr), RDX (long long size)
    ; Reverses the array using the stack (Keeping your original logic)
    MOV RCX,RDI
    MOV RDX,RSI

    MOV R8, 0           ; Counter i

.push_loop:
    CMP R8, RDX         ; While i < size
    JGE .end_push_loop  ; If i >= size, done pushing

    MOV R9, [RCX + R8*8] ; Load element array[i]
    PUSH R9             ; Push element onto stack (8 bytes for long long)

    INC R8              ; Increment i
    JMP .push_loop

.end_push_loop:

    MOV R8, 0           ; Reset counter i for popping

.pop_loop:
    CMP R8, RDX         ; While i < size
    JGE .end_pop_loop   ; If i >= size, done popping

    POP R9              ; Pop element from stack
    MOV [RCX + R8*8], R9 ; Store popped element back into array[i]

    INC R8              ; Increment i
    JMP .pop_loop

.end_pop_loop:
    RET
    
asm_find_min_in_array:
	MOV R8,0
	MOV RAX,[RDI]
forfind_min:
	INC R8
	CMP R8,RSI
	JGE ENDfind_min
	CMP RAX,[RDI+8*R8]
	JL forfind_min
	MOV RAX,[RDI+8*R8]
	JMP forfind_min
ENDfind_min:
	RET
	
asm_find_max_in_array:
	MOV R8,0
	MOV RAX,[RDI]
forfind_max:
	INC R8
	CMP R8,RSI
	JGE ENDfind_min
	CMP RAX,[RDI+8*R8]
	JG forfind_min
	MOV RAX,[RSI+8*R8]
	JMP forfind_min
ENDfind_max:
	RET

RET
asm_fibonachi:
    MOV R13,RDI
    MOV R8,0
    MOV R10,0
    MOV R11,1
    MOV R12,0
    CMP R13,1
    MOV R8,0

forfib:
    INC R8
    CMP R8,R13
    JGE endfib
    MOV R10,0
    ADD R10,R11
    ADD R10,R12
    MOV R12,R11
    MOV R11,R10
    MOV RAX,R12
    MOV RAX,R10
    JMP forfib

endfib:
    RET

toLowerCase:
    ; RDI holds the char* x (pointer to the string)

.loop_start:
    MOV AL, BYTE [RDI]   ; Load the character pointed to by RDI into AL
    CMP AL, 0            ; Check if it's the null terminator (end of string)
    JE .end_func         ; If it is, jump to the end

    CMP AL, 'A'          ; Check if character is less than 'a'
    JL .next_char        ; If so, skip conversion

    CMP AL, 'Z'          ; Check if character is greater than 'z'
    JG .next_char        ; If so, skip conversion

    ; If we reach here, AL contains a lowercase letter ('a' through 'z')
    ; According to your C code, it adds 32 to these.
    ADD AL, 32           ; Add 32 (converting 'a' to '{', 'b' to '|' etc.)
    MOV BYTE [RDI], AL   ; Store the modified character back into memory

.next_char:
    INC RDI              ; Move to the next character in the string (x++)
    JMP .loop_start      ; Continue looping

.end_func:
    RET
toUpperCase:
    ; RDI holds the char* x (pointer to the string)

.loop_starttoUpper:
    MOV AL, BYTE [RDI]   ; Load the character pointed to by RDI into AL
    CMP AL, 0            ; Check if it's the null terminator (end of string)
    JE .end_functoUpper         ; If it is, jump to the end

    CMP AL, 'a'          ; Check if character is less than 'a'
    JL .next_chartoUpper        ; If so, it's not a lowercase letter, skip conversion

    CMP AL, 'z'          ; Check if character is greater than 'z'
    JG .next_chartoUpper        ; If so, it's not a lowercase letter, skip conversion

    ; If we reach here, AL contains a lowercase letter ('a' through 'z')
    SUB AL, 32           ; Convert to uppercase by subtracting 32
    MOV BYTE [RDI], AL   ; Store the modified character back into memory

.next_chartoUpper:
    INC RDI              ; Move to the next character in the string (x++)
    JMP .loop_starttoUpper      ; Continue looping

.end_functoUpper:
    RET                  ; Return from the function

section .data
    prompt db "Enter a positive integer: ", 0
    result_msg db "Factorial: ", 0
    newline db 10, 0

section .bss
    number resb 1           ; Store user input number (1 byte)
    factorial resq 1        ; Store the factorial result (8 bytes for large results)

section .text
    global _start

_start:
    ; Prompt user for input
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; file descriptor: stdout
    mov rsi, prompt         ; message address
    mov rdx, 25             ; message length
    syscall

    ; Read user input
    mov rax, 0              ; syscall: read
    mov rdi, 0              ; file descriptor: stdin
    mov rsi, number         ; buffer address
    mov rdx, 1              ; read 1 character
    syscall

    ; Convert ASCII input to integer
    movzx rbx, byte [number]; Load input into RBX and zero-extend
    sub rbx, '0'            ; Convert ASCII to integer

    ; Initialize factorial result to 1
    mov rax, 1
    mov [factorial], rax

    ; Call factorial subroutine
    mov rdi, rbx            ; Pass input number in RDI
    call factorial_calc     ; Call subroutine

    ; Print result message
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; file descriptor: stdout
    mov rsi, result_msg     ; message address
    mov rdx, 10             ; message length
    syscall

    ; Print factorial result
    mov rax, [factorial]    ; Load result
    call print_number       ; Print the result

    ; Print newline
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; file descriptor: stdout
    mov rsi, newline        ; message address
    mov rdx, 1              ; message length
    syscall

    ; Exit program
    mov rax, 60             ; syscall: exit
    xor rdi, rdi            ; exit code
    syscall

factorial_calc:
    ; Calculate factorial (RDI contains input number)
    cmp rdi, 1              ; If number <= 1, return
    jle factorial_done

    ; Recursive factorial calculation
    mov rax, [factorial]    ; Load current factorial result
    imul rax, rdi           ; Multiply RAX by RDI (RAX *= RDI)
    mov [factorial], rax    ; Store the updated result

    dec rdi                 ; Decrement RDI
    call factorial_calc     ; Recursive call

factorial_done:
    ret                     ; Return to caller

print_number:
    ; Print number in RAX
    mov rbx, 10             ; Set divisor to 10
    xor rcx, rcx            ; Clear RCX (digit counter)
    mov rsi, rsp            ; Set RSI to point to stack (safe area)
print_loop:
    xor rdx, rdx            ; Clear RDX (remainder)
    div rbx                 ; Divide RAX by 10, quotient in RAX, remainder in RDX
    add dl, '0'             ; Convert remainder to ASCII
    dec rsi                 ; Move to the next position on stack
    mov [rsi], dl           ; Store ASCII character
    inc rcx                 ; Increment digit counter
    test rax, rax           ; Check if quotient is 0
    jnz print_loop          ; If not, continue dividing

print_digits:
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; file descriptor: stdout
    mov rdx, 1              ; Write 1 byte
    lodsb                   ; Load byte at RSI into AL
    syscall
    loop print_digits       ; Repeat for all digits
    ret

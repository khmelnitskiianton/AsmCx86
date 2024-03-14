;========================================================================================
;Convention
;RSP, RBP, RBX, R12, R13, R14, R15 - nonvalotile save in stack by called function
;RAX, RCX, RDX, RSI, RDI, R8, R9, R10, R11, - valotile save by code which calls
;ABI GCC:       ;r9d - first 6 arguments in registers, than stack
                ;r8d
                ;ecx
                ;edx
                ;esi
                ;edi 
;Convention Syscall:
                ;rdi - args for syscall
                ;rsi
                ;rdx
                ;r11
                ;r10
                ;r8
                ;r9
;========================================================================================

section .text

global Printf32
global print_char
global print_string

_format_str     equ 16
_stack_offset   equ 8

;----------------------------------------FUNCTIONS---------------------------------------
;Printf32(...) - function supporting because of ABI
;DON'T CHANGE R10

Printf32: 
        nop
                
        pop  r10        ; pop in r11 address of call
        
        push r9         ; save all regs in stack
        push r8         ; now i have all args in stack
        push rcx
        push rdx
        push rsi
        push rdi
        
        call printf_32  ;call main printf_32
        
        add  rsp, 48    ;free 6 stack-regs args
        
        push r10        ;put in stack address of return from Printf32
        ret
;----------------------------------------------------------------------------------------
;printf_32(char* buffer, ...) - function prints string from buffer
;Args: ABI - arguments in stack
;Ret: void
;Change: rbx, rdi, rcx, r12

printf_32:
        nop
        ;input action
        push rbp        ; save rbp
        mov rbp, rsp    ; new rbp = rsp
        ;sub rsp,n      ;local vars
        ;-------------------------------
        
        xor rcx, rcx                            ;rcx - offset for argument of %
        mov r12, rbp                            ;r12 - current argument of printf
        add r12, _format_str
        add r12, _stack_offset
        mov rbx, qword [rbp+_format_str]        ;rbx - address on buffer

.while_start:                                   ;while(*ch != '\0') {print_char(*ch)}
        cmp byte [rbx], 0    ; *ch != '\0'
        je .while_end
        ;check for % - format string
.if_start:
        cmp byte [rbx], '%'
        jne .if_else
        inc rbx         ;set arg of % 
        ;check if last symbol was %
        cmp byte [rbx], 0    ; *ch != '\0'
        je .while_end
        ;-------------------------------
        ;cases:
        ;1) %%
        cmp byte [rbx], '%'
        je .if_else     ;just print symbol in else
        ;2) %c
        cmp byte [rbx], 'c'
        je .case_char
        ;3) %s
        cmp byte [rbx], 's'
        je .case_string 

.if_else:
        ;if simple symbol just out
        xor rdi, rdi         ;set rdi = 0
        mov dil, byte [rbx]  ;mov rdi(dil = 1 byte), [rbx] 
        push rax        ;save regs of syscall
        push rsi
        push rdx
        call print_char ;call print current char
        pop rdx         ;revive regs
        pop rsi
        pop rax         
        jmp .if_end
;Tables of jumps for cases of %
.table_of_jmps:
.case_char:
        mov rdi, [r12]
        push rax        ;save regs
        push rsi
        push rdx
        call print_char ;call func
        pop rdx         ;revive regs
        pop rsi
        pop rax     
        jmp .end_case
.case_string:
        push rdi        ;save regs
        push rbx
        mov rdi, [r12]
        call print_string ;call func
        pop rbx         ;revive regs
        pop rdi
        jmp .end_case
;case_decimal:
;
;case_hex:
.end_case:
        add r12, _stack_offset
.if_end:
        ;set next symbol
        inc rbx
        jmp .while_start
.while_end:
        leave           ;mov rsp, rbp ; free stack from local vars and all rubbish
                        ;pop rbp      ; revive rbp
        ret             ; return to last position
;----------------------------------------------------------------------------------------
;print_char(int a) - function of write one char symbol in stdout
;Args: ABI - argument in rdi
;Ret: void
;Change: rdi, rax, rsi, rdx
print_char:
        nop
        nop
        nop
        push rdi
        mov rax, 0x01      ; syscall 0x01: write(rdi, rsi, rdx) - (int, char*, size_t)
        mov rdi, 1         ; stdout
        mov rsi, rsp       ; address of str - in stack last char
        mov rdx, 1         ; length = 1 (one char)
        syscall
        pop rdi
        ret
;----------------------------------------------------------------------------------------
;print_string(const char* buff) - function of write string in stdout
;Args: ABI - argument in rdi
;Ret: void
;Change: rdi, rbx
print_string:
        ;while(*ch != '\0') {print_char(*ch)}
        push rdi
        mov rbx, rdi   ;rbx - address on buffer
.while_start:
        cmp byte [rbx], 0    ; *ch != '\0'
        je .while_end
        xor rdi, rdi         ;set rdi = 0
        mov dil, byte [rbx]  ;mov rdi(dil = 1 byte), [rbx] 
        push rax        ;save regs of syscall
        push rsi
        push rdx
        call print_char ;call print current char
        pop rdx         ;revive regs
        pop rsi
        pop rax         
        ;set next symbol
        inc rbx
        jmp .while_start
.while_end:
        pop rdi
        ret
;----------------------------------------------------------------------------------------
;print_decimal(int a) - function of write decimal number
;Args: ABI - argument in rdi
;Ret: void
;Change:
;print_decimal:
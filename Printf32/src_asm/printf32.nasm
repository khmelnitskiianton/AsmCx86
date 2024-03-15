;========================================================================================
;                               MAIN NASM FOR PRINTF32
;========================================================================================

%include "./src_asm/lib.inc"

global Printf32

extern print_char
extern print_str
extern print_dec_sign
extern print_dec_unsign
extern print_hex
extern print_oct
extern print_bin
extern print_addr

section .text

;=========================================FUNCTIONS======================================
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
        
        pop rdi         ;revive all args
        pop rsi
        pop rdx
        pop rcx
        pop r8
        pop r9

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
        push rbx
        mov r12, rbp                            ;r12 - current argument of printf
        add r12, _format_str
        add r12, _stack_offset
        mov rbx, qword [rbp+_format_str]        ;rbx - address on buffer
        xor rcx, rcx                            ;counter of output args
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
        ;4.1) %d
        cmp byte [rbx], 'd'
        je .case_decimal_signed
        ;4.2) %u
        cmp byte [rbx], 'u'
        je .case_decimal_unsigned
        ;5) %x
        cmp byte [rbx], 'x'
        je .case_hexadecimal
        ;6) %o
        cmp byte [rbx], 'o'
        je .case_octal
        ;6) %b
        cmp byte [rbx], 'b'
        je .case_binary
        ;7) %n
        cmp byte [rbx], 'n'
        je .case_count
        ;7) %p
        cmp byte [rbx], 'p'
        je .case_address
.if_else:
        ;if simple symbol just out
        xor rdi, rdi         ;set rdi = 0
        mov dil, byte [rbx]  ;mov rdi(dil = 1 byte), [rbx] 

        call print_char ;call print current char

        jmp .if_end
;Tables of jumps for cases of %
.cases_of_jmps:
.case_char:
        mov rdi, [r12]
        call print_char
        jmp .end_case
.case_string:
        mov rdi, [r12]
        call print_str
        jmp .end_case
.case_decimal_signed:
        mov rdi, [r12]
        call print_dec_sign
        jmp .end_case
.case_decimal_unsigned:
        mov rdi, [r12]
        call print_dec_unsign
        jmp .end_case
.case_hexadecimal:
        mov rdi, [r12]
        call print_hex
        jmp .end_case
.case_octal:
        mov rdi, [r12]
        call print_oct
        jmp .end_case
.case_binary:
        mov rdi, [r12]
        call print_bin
        jmp .end_case
.case_count:
        mov rdi, rcx
        call print_dec_unsign
        jmp .end_case
.case_address:
        mov rdi, [r12]
        call print_addr
        jmp .end_case
.end_case:
        inc rcx
        add r12, _stack_offset
.if_end:
        ;set next symbol
        inc rbx
        jmp .while_start
.while_end:
        pop rbx
        leave           ;mov rsp, rbp ; free stack from local vars and all rubbish
                        ;pop rbp      ; revive rbp
        ret             ; return to last position
;========================================================================================
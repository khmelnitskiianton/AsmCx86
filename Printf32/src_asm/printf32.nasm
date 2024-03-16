;========================================================================================
;                               MAIN NASM FOR PRINTF32                                  |
;========================================================================================

%include "./src_asm/lib.inc"
  
global Printf32

section .text

;========================================MAIN=FUNCTION===================================
;Printf32(...) - function supporting because of ABI
;DON'T CHANGE R10, R11 - GLOBAL REGS!!!
;DON'T CHANGE R8,R9 - TABLE OF JMPS DON'T SAVE THEM
Printf32: 
        nop
                
        pop  r10        ; pop in r10 address of call
        
        push r9         ; save all regs in stack
        push r8         ; now i have all args in stack
        push rcx
        push rdx
        push rsi
        push rdi
        
        push rbp        ;save regs by convention
        push rbx 
        push r12 
        push r13 
        push r14 
        push r15

        call printf_32  ;call main printf_32
        
        pop r15         ;revive regs
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp

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
;Change: rbx, rdi, rcx, r12, r13, r14, r15
printf_32:
        nop
        ;input action
        push rbp        ; save rbp
        mov rbp, rsp    ; new rbp = rsp
        ;sub rsp,n      ;local vars
        ;-------------------------------
        mov rax, FAIL_RET       ;default - before ending fail return
        xor r11, r11            ;clean r11
        xor r15, r15
        mov r12, rbp            ;r12 - current argument of printf
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
        je .error_return
        ;-------------------------------
        ;cases: 
        xor r14, r14
        mov r14b, byte [rbx]
        ;1) %%
        cmp r14b, '%'
        je .if_else     ;just print symbol in else
        ;2) %n
        cmp r14b, 'n'
        jne .jmp_for_table
        add r15, r11
        mov r14, [r12]
        mov [r14], r15d ;put dword amount of symbols in &b 
        jmp .return_place
.jmp_for_table:
        mov rdi, [r12]
        mov r13, [r14*8 + jump_table_of_printf - 'b'*8] ;offset
        jmp r13         ;jmp on function
.return_place:
        inc rcx
        add r12, _stack_offset
        jmp .if_end
.if_else:
        ;if simple symbol just out
        xor rdi, rdi         ;set rdi = 0
        mov dil, byte [rbx]  ;mov rdi(dil = 1 byte), [rbx] 
        call print_char

        jmp .if_end
.if_end:
        ;set next symbol
        inc rbx
        jmp .while_start
.while_end:
.if_buff_start: ;if(buffer not empty){write}
        cmp r11, 0
        je .if_buff_end 
        call write_buff
.if_buff_end:
        mov rax, SUCCESS_RET      ;rax - return value - success
        jmp .end_return
.error_return:
        mov rax, FAIL_RET       ;default - before ending fail return
.end_return:
        leave           ;mov rsp, rbp ; free stack from local vars and all rubbish
                        ;pop rbp      ; revive rbp
        ret             ; return to last position
;========================================================================================

;WARNING: ALL FUNCTIONS CANT CHANGE R10 & R11 - RESERVED
;R10 - address of return from printf
;R11 - counter of buffer

;==================================HELP=FUNCTIONS========================================
;write_buff() - function of write buffer in stdout
;Args: ABI - r11 - global counter of buffer, "buffer_out" - buffer with string
;Ret: void
;Change: nothing
write_buff:
        push r11
        push rax        ;save regs of syscall
        push rcx
        push rsi
        push rdx
        push rdi

        add r15, r11    ;global 

        mov rax, SYSCALL_WRITE ; syscall 0x01: write(rdi, rsi, rdx) - (int, char*, size_t)
        mov rdi, 1              ; stdout
        mov rsi, buffer_out     ; address of str - in stack last char
        mov rdx, r11             ; length
        syscall
                
        pop rdi          ;revive regs
        pop rdx        
        pop rsi
        pop rcx
        pop rax  
        pop r11

        ret 
;========================================================================================
;print_char(int a) - function of write one char symbol in stdout
;Args: ABI - argument in rdi, r11 - global counter of buffer
;Ret: void
;Change: buffer_out, r11
print_char:
        nop
        ;if (size_buff<=r11) {write, clear}
.if_start:
        cmp r11, SIZE_BUFFER
        jb .if_end 
 
        call write_buff

        push rcx
        mov rcx, r11
.for_start:
        mov buffer_out[rcx], byte 0
        loop .for_start
        pop rcx
        mov r11, 0
.if_end:
        mov buffer_out[r11], dil
        inc r11
        ret
;========================================================================================
;print_ch(int a) - function of write one char symbol in stdout
;Args: ABI - argument in rdi, r11 - global counter of buffer
;Ret: void
;Change: nothing
print_ch:
        call print_char
        jmp printf_32.return_place
;----------------------------------------------------------------------------------------
;print_str(const char* buff) - function of write string in stdout
;Args: ABI - argument in rdi
;Ret: void
;Change: rdi, rbx
print_str:
        nop
        push rdi        ;save regs
        push rbx
        ;while(*ch != '\0') {print_char(*ch)}
        mov rbx, rdi   ;rbx - address on buffer
.while_start:
        cmp byte [rbx], 0    ; *ch != '\0'
        je .while_end
        xor rdi, rdi         ;set rdi = 0
        mov dil, byte [rbx]  ;mov rdi(dil = 1 byte), [rbx] 

        call print_char ;call print current char

        ;set next symbol
        inc rbx
        jmp .while_start
.while_end:
        pop rbx         ;revive regs
        pop rdi
        jmp printf_32.return_place
;----------------------------------------------------------------------------------------
;print_dec_sign(int a) - function of write decimal number
;Args: ABI - argument in rdi
;Ret: void
;Change: rsi, rcx, rdi, rax, rdx, r8, r9
print_dec_sign:
        nop

        push rsi        ;save regs
        push rcx
        push rdi
        push rax
        push rdx

        mov rax, rdi     ;rax = number
        mov r8, 10
        cmp eax, 0       ;Use eax, because its 32byte signed number
        jl .case_neg
        jmp .end_case
.case_neg:              ;case of negative number
        neg eax         ;Make signed 32byte number - unsigned
        mov dil, '-'
        call print_char ;call print current char
.end_case:
        ;printing digits
        ;div: rax - quotient, rdx - remains 
        xor rcx, rcx    ;rcx - counter of digits
        xor rdx, rdx
.while_start:           ;do{...}while(rax != 0)
        cqo             ;expand rax to rdx:rax for dividing
        div r8       
        xor r9, r9
        mov r9b, dec_str[rdx]
        push r9
        inc rcx         ;inc rcx
        cmp rax, 0
        je .while_end
        jmp .while_start
.while_end:
        xor rdi, rdi
.for_begin:             ;loop: print all digits from stack
        pop rdi         
        call print_char ;print char
        loop .for_begin

        pop rdx         ;revive regs
        pop rax
        pop rdi
        pop rcx
        pop rsi

        jmp printf_32.return_place
;----------------------------------------------------------------------------------------
;print_dec_unsign(int a) - function of write decimal number
;Args: ABI - argument in rdi
;Ret: void
;Change: rsi, rcx, rdi, rax, rdx, r8, r9
print_dec_unsign:
        nop
        
        push rsi        ;save regs
        push rcx
        push rdi
        push rax
        push rdx
        
        mov rax, rdi     ;rax = number
        mov r8, 10
        ;printing digits
        ;div: rax - quotient, rdx - remains 
        xor rcx, rcx    ;rcx - counter of digits
.while_start:           ;do{...}while(rax != 0)
        cqo             ;expand rax to rdx:rax for dividing
        div r8       
        xor r9, r9
        mov r9b, dec_str[rdx]
        push r9
        inc rcx         ;inc rcx
        cmp rax, 0
        je .while_end
        jmp .while_start
.while_end:
        xor rdi, rdi
.for_begin:             ;loop: print all digits from stack
        pop rdi         
        call print_char ;print char
        loop .for_begin
        
        pop rdx         ;revive regs
        pop rax
        pop rdi
        pop rcx
        pop rsi
        
        jmp printf_32.return_place
;----------------------------------------------------------------------------------------
;print_hex(int a) - function of write hexiamal number
;Args: ABI - argument in rdi - number
;Ret: void
;Change: rsi, rcx, rdi, rax, rdx, r8
print_hex:
        nop
        
        push rsi        ;save regs
        push rcx
        push rdi
        push rax
        push rdx
        
        mov rax, rdi     ;rax = number
        ;print prefix "0x" with macros
%ifdef  HEX_PREFIX
        xor rdi,rdi
        mov rdi, '0'
        call print_char
        mov rdi, 'x'
        call print_char
%endif
        ;printing digits
        ;div: rax - quotient, rdx - remains 
        xor rcx, rcx    ;rcx - counter of digits
.while_start:           ;do{...}while(rax != 0)
        xor rdx, rdx
        mov dx, ax      ;in dx - digit
        and dx, 15      
        xor r8, r8
        mov r8b, hex_str_small[rdx]
        push r8
        shr rax, 4      ;dividing on 16
        inc rcx         ;inc rcx
        test rax, rax      ;test rax,rax
        je .while_end
        jmp .while_start
.while_end:
        xor rdi, rdi
.for_begin:             ;loop: print all digits from stack
        pop rdi         
        call print_char ;print char
        loop .for_begin
                
        pop rdx         ;revive regs
        pop rax
        pop rdi
        pop rcx
        pop rsi
        
        jmp printf_32.return_place
;----------------------------------------------------------------------------------------
;print_oct(int a) - function of write octal number
;Args: ABI - argument in rdi - number
;Ret: void
;Change: rsi, rcx, rdi, rax, rdx, r8
print_oct:
        nop
        
        push rsi        ;save regs
        push rcx
        push rdi
        push rax
        push rdx
        
        mov rax, rdi     ;rax = number
        ;print "0o"
%ifdef  OCT_PREFIX
        xor rdi,rdi
        mov rdi, '0'
        call print_char
        mov rdi, 'o'
        call print_char
%endif
        ;printing digits
        ;div: rax - quotient, rdx - remains 
        xor rcx, rcx    ;rcx - counter of digits
.while_start:           ;do{...}while(rax != 0)
        xor rdx, rdx
        mov dx, ax      ;in dx - digit
        and dx, 7       ;dx - remains dx % 7
        xor r8, r8
        mov r8b, oct_str[rdx]
        push r8
        shr rax, 3      ;dividing on 8
        inc rcx         ;inc rcx
        test rax, rax      ;test rax,rax
        je .while_end
        jmp .while_start
.while_end:
        xor rdi, rdi
.for_begin:             ;loop: print all digits from stack
        pop rdi         
        call print_char ;print char
        loop .for_begin
                        
        pop rdx         ;revive regs
        pop rax
        pop rdi
        pop rcx
        pop rsi
        
        jmp printf_32.return_place
;----------------------------------------------------------------------------------------
;print_bin(int a) - function of write binary number
;Args: ABI - argument in rdi - number
;Ret: void
;Change: rsi, rcx, rdi, rax, rdx
print_bin:
        nop
                
        push rsi        ;save regs
        push rcx
        push rdi
        push rax
        push rdx
        
        mov rax, rdi     ;rax = number
        ;print "0o"
%ifdef  BIN_PREFIX
        xor rdi,rdi
        mov rdi, '0'
        call print_char
        mov rdi, 'b'
        call print_char
%endif
        ;printing digits
        ;div: rax - quotient, rdx - remains 
        xor rcx, rcx    ;rcx - counter of digits
.while_start:           ;do{...}while(rax != 0)
        xor rdx, rdx
        mov dx, ax      ;in dx - digit
        and dx, 1       ;dx - remains
        xor r8, r8
        mov r8b, bin_str[rdx]
        push r8
        shr rax, 1      ;dividing on 2
        inc rcx         ;inc rcx
        test rax, rax      ;test rax,rax
        je .while_end
        jmp .while_start
.while_end:
        xor rdi, rdi
.for_begin:             ;loop: print all digits from stack
        pop rdi         
        call print_char ;print char
        loop .for_begin
                        
        pop rdx         ;revive regs
        pop rax
        pop rdi
        pop rcx
        pop rsi
        
        jmp printf_32.return_place
;----------------------------------------------------------------------------------------
;print_addr(int a) - function of write hexiamal number
;Args: ABI - argument in rdi - number
;Ret: void
;Change: rsi, rcx, rdi, rax, rdx, r8
print_addr:
        nop
                
        push rsi        ;save regs
        push rcx
        push rdi
        push rax
        push rdx
        
        mov rax, rdi     ;rax = number
        ;print prefix "0x" with macros
%ifdef  ADDR_PREFIX
        xor rdi,rdi
        mov rdi, '0'
        call print_char
        mov rdi, 'x'
        call print_char
%endif
        ;printing digits
        ;div: rax - quotient, rdx - remains 
        mov rcx, 15
.while_start:           ;do{...}while(rax != 0)
        xor rdx, rdx
        mov dx, ax      ;in dx - digit
        and dx, 15      
        xor r8, r8
        mov r8b, hex_str_small[rdx]
        push r8  ; push digit symbol
        shr rax, 4      ;dividing on 16
        cmp rcx, 0
        je .while_end
        dec rcx
        jmp .while_start
.while_end:
        xor rdi, rdi
        mov rcx, 16
.for_begin:         ;loop: print all digits from stack
        pop rdi         
        cmp rdi, '0'
        je .skip_zero
        call print_char ;print char
.skip_zero:
        loop .for_begin
                        
        pop rdx         ;revive regs
        pop rax
        pop rdi
        pop rcx
        pop rsi
        
        jmp printf_32.return_place
;========================================================================================

;=====================================DATA=SECTION=======================================

section .rodata
;ABCDEFGHIJKLMNOPQRSTUVWXYZ
;b c d n o p s u x
error_buffer:          ;Extra buffer before & after jmp table if user write %????
        times 'b'+1     dq      printf_32.error_return  ;error buffer before '\0'-'b'
jump_table_of_printf:
                        dq      print_bin
                        dq      print_ch
                        dq      print_dec_sign
        times 'o'-'d'-1 dq      printf_32.error_return
                        dq      print_oct
                        dq      print_addr
        times 's'-'p'-1 dq      printf_32.error_return
                        dq      print_str
        times 'u'-'s'-1 dq      printf_32.error_return
                        dq      print_dec_unsign
        times 'x'-'u'-1 dq      printf_32.error_return
                        dq      print_hex
        times 127-'x'+1 dq      printf_32.error_return  ;error buffer after '~'-'x'

section .rodata
;const alphabets for number systems
bin_str:        db "01"
oct_str:        db "01234567"
dec_str         db "0123456789"
hex_str_big:    db "0123456789ABCDEF"
hex_str_small:  db "0123456789abcdef"

section .data
;buffer for write
buffer_out:     times SIZE_BUFFER db 0

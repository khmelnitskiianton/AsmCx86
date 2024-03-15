;=========================================================================================
;                                   Function for Print32
;=========================================================================================

;1) syscall every time -> buffer
;2) jmp table
;3) check functions with conventions

%include "./src_asm/lib.inc"

global print_char
global print_str
global print_dec_sign
global print_dec_unsign
global print_hex
global print_oct
global print_bin
global print_addr

section .rodata

bin_str:        db "01"
oct_str:        db "012345467"
dec_str         db "0123456789"
hex_str_big:    db "0123456789ABCDEF"
hex_str_small:  db "0123456789abcdef"

section .text

;==================================FUNCTIONS=============================================
;print_char(int a) - function of write one char symbol in stdout
;Args: ABI - argument in rdi
;Ret: void
;Change: rdi, rax, rsi, rdx, rcx
print_char:
        nop
        push r11
        push rax        ;save regs of syscall
        push rcx
        push rsi
        push rdx
        push rdi

        mov rax, SYSCALL_WRITE ; syscall 0x01: write(rdi, rsi, rdx) - (int, char*, size_t)
        mov rdi, 1         ; stdout
        mov rsi, rsp       ; address of str - in stack last char
        mov rdx, 1         ; length = 1 (one char)
        syscall
                
        pop rdi          ;revive regs
        pop rdx        
        pop rsi
        pop rcx
        pop rax  
        pop r11
        ret
;----------------------------------------------------------------------------------------
;print_str(const char* buff) - function of write string in stdout
;Args: ABI - argument in rdi
;Ret: void
;Change: rdi, rbx
print_str:
        nop
        push rcx
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
        pop rcx
        ret
;----------------------------------------------------------------------------------------
;print_dec_sign(int a) - function of write decimal number
;Args: ABI - argument in rdi
;Ret: void
;Change: rsi, rcx, rdi, rax, rdx, r8, r9
print_dec_sign:
        nop
        push rcx
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
        pop rcx
        ret
;----------------------------------------------------------------------------------------
;print_dec_unsign(int a) - function of write decimal number
;Args: ABI - argument in rdi
;Ret: void
;Change: rsi, rcx, rdi, rax, rdx, r8, r9
print_dec_unsign:
        nop
        push rcx
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
        pop rcx
        ret
;----------------------------------------------------------------------------------------
;print_hex(int a) - function of write hexiamal number
;Args: ABI - argument in rdi - number
;Ret: void
;Change: rsi, rcx, rdi, rax, rdx, r8
print_hex:
        nop
        push rcx
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
        mov r8b, dec_str[rdx]
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
        pop rcx
        ret
;----------------------------------------------------------------------------------------
;print_oct(int a) - function of write octal number
;Args: ABI - argument in rdi - number
;Ret: void
;Change: rsi, rcx, rdi, rax, rdx, r8
print_oct:
        nop
        push rcx
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
        pop rcx
        ret
;----------------------------------------------------------------------------------------
;print_bin(int a) - function of write binary number
;Args: ABI - argument in rdi - number
;Ret: void
;Change: rsi, rcx, rdi, rax, rdx
print_bin:
        nop
        push rcx
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
        pop rcx
        ret
;----------------------------------------------------------------------------------------
;print_addr(int a) - function of write hexiamal number
;Args: ABI - argument in rdi - number
;Ret: void
;Change: rsi, rcx, rdi, rax, rdx, r8
print_addr:
        nop
        push rcx
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
        pop rcx
        ret
;========================================================================================
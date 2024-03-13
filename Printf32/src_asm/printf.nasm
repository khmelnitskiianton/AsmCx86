;Function of Summ with args and ret arg
;Convention
;RSP, RBP, RBX, R12, R13, R14, R15 - nonvalotile save in stack by called function
;RAX, RCX, RDX, RSI, RDI, R8, R9, R10, R11 - valotile save by code which calls
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
                ;r10
                ;r8
                ;r9

section .text

global Printf32
global print_char

;--------------------------FUNCTIONS---------------------------
;print_char(int a) - function of write one char symbol in stdout
;Args: ABI - argument in rdi
;Ret: void
;Change: rdi, rax, rsi, rdx
print_char:
        push rdi
        mov rax, 0x01      ; syscall 0x01: write(rdi, rsi, rdx) - (int, char*, size_t)
        mov rdi, 1         ; stdout
        mov rsi, rsp       ; address of str - in stack last char
        mov rdx, 1         ; length = 1 (one char)
        syscall
        pop rdi
        ret
;---------------------------------------------------------------
;print_string(char* buffer) - function prints string from buffer
;Args: ABI - argument in rdi
;Ret: void
;Change: rbx, rdi
Printf32:
        ;while(*ch != '\0') {print_char(*ch)}
        push rdi
        mov rbx, rdi   ;rbx - address on buffer
while_start:
        cmp byte [rbx], 0    ; *ch != '\0'
        je while_end
        ;check for % - format string
if_start:
        cmp byte [rbx], '%'
        jne if_else
        inc rbx         ;set arg of % 
        ;1) %%
        cmp byte [rbx], '%'
        je if_else     ;just print symbol in else

        jmp if_end
if_else:
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
        ;set next symbol
if_end:
        inc rbx
        jmp while_start
while_end:
        pop rdi
        ret
;----------------------------------------------------------------
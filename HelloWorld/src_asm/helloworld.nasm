;Function of HelloWorld

section .data           ;Section of data
            
Msg:        db "Hello World!", 0x0a     ;buffer of string 
MsgLen      equ $ - Msg                 ;$ - current address, <$-Msg> - has value=length of str

section .text           ;Section of text

global HelloWorld       ;Set function HelloWorld global 

HelloWorld:
        mov rax, 0x01      ; write64 (rdi, rsi, rdx)
        mov rdi, 1         ; stdout
        mov rsi, Msg       ; address of string
        mov rdx, MsgLen    ; strlen (Msg)
        syscall
        ret
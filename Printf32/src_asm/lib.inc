;========================================================================================
;                              LIB FOR MACROSES & DEFINE & CONVENTION                   |
;========================================================================================
SYSCALL_WRITE   equ 0x01
SIZE_BUFFER     equ 10
_format_str     equ 16+48   ;16, 48 - 6 regs by convension i push
_stack_offset   equ 8
SUCCESS_RET     equ 1
FAIL_RET        equ 0
;========================================================================================
;TWO DEFINES OF WRITING "0x""0o""0b" IN PREFIXIES OF DIFFRENT NUMBER SYSTEMS
%define HEX_PREFIX 1
%define OCT_PREFIX 1
%define BIN_PREFIX 1
%define ADDR_PREFIX 1
;========================================================================================
;Convention Function
;RSP, RBP, RBX, R12, R13, R14, R15 - nonvalotile save in stack by called function
;RAX, RCX, RDX, RSI, RDI, R8, R9, R10, R11, - valotile save by code which calls
;ABI GCC:       ;r9d - first 6 arguments in registers, than stack
                ;r8d
                ;ecx
                ;edx
                ;esi
                ;edi
                ;rax - return reg 
;Convention Syscall:
                ;rcx
                ;rdi - args for syscall
                ;rsi
                ;rdx
                ;r11
                ;r10
                ;r8
                ;r9
;========================================================================================
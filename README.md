## GAS

`sudo apt-get install build-essential`

```bash
gcc -c -o 0-Linux-as.o 0-Linux-as.s                     #GNU Compiler
as  -a -o 0-Linux-as.o 0-Linux-as.s > 0-Linux-as.lst    #GNU Asm 
ld  -s -o 0-Linux-as   0-Linux-as.o                     #GNU linker
```

`-c` compiles and assembles files but doesn't link them.

`-o` <filename> compiles and links files into an executable named <filename>

`.intel_syntax noprefix`  - set GAS to change from AT&T to Intel syntax!

## NASM

`sudo apt install nasm`

```bash
nasm -f elf -l 0-Linux-nasm.lst 0-Linux-nasm.s      #NASM assembler
ld   -s -m elf_i386 -o 0-Linux-nasm 0-Linux-nasm.o  #Linker
```

`-f elf` - `-f` - option with argument - format of file. It translate if ELF-file.
`-f elf64` - in ELF-file x64 system. `-f bin` - simple binary file

`-m elf_i386` - option of link on some architecture. `ld -V` - list of available

## My programs

GCC - to compile into an obj file

NASM - to assemble in Linux x86 assembler programs

GCC - to link all files with option `-no-pie`

## Makefile

[```Makefile```](https://github.com/khmelnitskiianton/AsmCx86/blob/main/Makefile)

Need folders `./bin` `./obj` `./src_asm` `./src_c` in current directory with makefile

*Commands*:
`make`
`make clean`

## Links

+ [Call Convention](https://en.wikipedia.org/wiki/X86_calling_conventions)
+ [NASM Guide](https://metanit.com/assembler/nasm/7.1.php)
+ [Best Compiler](https://godbolt.org/)
+ [Linux Syscall](https://syscalls.mebeim.net/?table=x86/64/x64/v6.5)
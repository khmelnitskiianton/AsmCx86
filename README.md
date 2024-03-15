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
`make run`

## NASM

`sudo apt install nasm`

```bash
nasm -f elf -l 0-Linux-nasm.lst 0-Linux-nasm.s      #NASM assembler
ld   -s -m elf_i386 -o 0-Linux-nasm 0-Linux-nasm.o  #Linker
```

`-f elf` - `-f` - option with argument - format of file. It translate if ELF-file.
`-f elf64` - in ELF-file x64 system. `-f bin` - simple binary file

`-m elf_i386` - option of link on some architecture. `ld -V` - list of available

## Links

+ [Call Convention](https://en.wikipedia.org/wiki/X86_calling_conventions)
+ [NASM Guide](https://metanit.com/assembler/nasm/7.1.php)
+ [Best Compiler](https://godbolt.org/)
+ [Linux Syscall](https://syscalls.mebeim.net/?table=x86/64/x64/v6.5)
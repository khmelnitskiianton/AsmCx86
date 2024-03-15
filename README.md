# AsmCx86

Programs on NASM+C on Linux x86-64

## Printf

Simple version of printf() on NASM on Linux x86-64:

[```Printf32.nasm```]((https://github.com/khmelnitskiianton/AsmCx86/blob/main/Printf32/src_asm/printf32.nasm))

[```lib.inc```]((https://github.com/khmelnitskiianton/AsmCx86/blob/main/Printf32/src_asm/lib.ink))

*Specifiers*:

+ `%c` - char symbol
+ `%s` - string
+ `%d` - signed integer number(32-byte)
+ `%u` - unsigned integer number(64-byte)
+ `%o` - octal integer number(64-byte)
+ `%x` - hexiamal integer number(64-byte)
+ `%b` - binary integer number(64-byte)
+ `%p` - pointer address in hex(64-byte)
+ `%n` - writes in address the number of characters outputted so far

*Return:*
+ `1` if success
+ `0` if fail or error

*Examples:*

```cpp
int a = Printf32("%o\n%d %s %x %d%%%c%b\n%d %s %x %d%%%c%b", -1, -1, "love", 3802, 100, 33, 127,
                                                                 -1, "love", 3802, 100, 33, 127);
Output:
0o36666666666
-1 love 0x430 100%!0b1111111
-1 love 0x430 100%!0b1111111
```cpp
int b = 1;
Printf32("abba%n-best\n", &b);
Printf32("%d\n", b);
Output:
abba-best
4
```

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
## Printf32()

Simple version of printf() on NASM on Linux x86-64:

[```Printf32.nasm```](https://github.com/khmelnitskiianton/AsmCx86/blob/main/Printf32/src_asm/printf32.nasm)

[```lib.inc```](https://github.com/khmelnitskiianton/AsmCx86/blob/main/Printf32/src_asm/lib.inc)

*Specifiers*:

+ `%c` - char symbol
+ `%s` - string
+ `%d` - signed integer number(32-byte)
+ `%u` - unsigned integer number(64-byte)
+ `%o` - octal integer number(64-byte)
+ `%x` - hexiamal integer number(64-byte)
+ `%b` - binary integer number(64-byte)
+ `%p` - pointer address in hex(64-byte)
+ `%n` - writes in address the number of characters outputted so far (32-byte)

*Options:*
- If tou want disable/enable prefixies in diffrent number systems ("0o" "0x" "0b") comment `%define HEX_PREFIX 1` and etc in [```lib.inc```](https://github.com/khmelnitskiianton/AsmCx86/blob/main/Printf32/src_asm/lib.inc)

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
```
```cpp
int b = 1;
Printf32("abba%n-best\n", &b);
Printf32("%d\n", b);
Output:
abba-best
4
```
## Mandelbrot set

[Main Code](https://github.com/khmelnitskiianton/AsmCx86/blob/main/Mandelbrot/src_c/main.cpp)

Project of testing optimization on Mandelbrot set visualization.

*System*: Linux x86-64, CPU: Intel Core i5-12450H, 3MHz

*Drawing*:

- I draw Mandelbrot set with SDL2 on C
- Visualization has interface: &#8592;,&#8593;,&#8594;,&#8595; for moving and -,+ for zoom set. Also Window can change size.
- In the angle drawing actual FPS of rendering set.

*Optimiztion:*

I have 3 versions of code:

1. Naked algorithm `DrawMandelbrot1`
2. Algorithm using merging 4 pixel in line in one operation `DrawMandelbrot2`
3. Using vectorization AVX/AVX2 `DrawMandelbrot3`

Use: press 1,2,3 while running program and see different fps.

*Example of vizualization*:

<img src="https://github.com/khmelnitskiianton/AsmCx86/assets/142332024/38b9466e-ba93-45fc-8627-9c8a55e54ce4" width=70%>

*Tests & Results*:

|Version|GCC `-O3`|FPS|
|-------|---------|---|
|   1   |   off   |4|
|   1   |   on    |7.5|
|   2   |   off   |1.6|
|   2   |   on    |9.8|
|   3   |   off   |11|
|   3   |   on    |28|

*Conclusion*:

Comparing 3 types of code: 1 - nake algotithm, 2 - with merging 4 pixels in loop, 3 - with vectorization AVX/AVX2.

To sum up, v.3 with vectorization have highest result 28 fps & without - 7.5. Boost in 4 times is insane with using -03 gcc & AVX2!

## Settings

*Compilation & Linking*:

GCC - to compile into an obj file

NASM - to assemble in Linux x86 assembler programs

GCC - to link all files with option `-no-pie`

*Makefile*:

[```Makefile```](https://github.com/khmelnitskiianton/AsmCx86/blob/main/Makefile)

Need folders `./bin` `./obj` `./src_asm` `./src_c` in current directory with makefile

*Commands*:
`make`
`make clean`
`make run`

*NASM:*

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

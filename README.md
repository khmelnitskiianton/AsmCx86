# AsmCx86
Projects are writen on C+Assembler x86-64

1. [Printf32()](#printf32) - simple realization of printf() on NASM
2. [Mandelbrot set](#mandelbrot-set) - vizualization of Mandelbrot set on SDL,with measuring fps and application AVX instruction for optimization(searching for speed of rendering frame)

## Printf32

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

*System & Compilier*: Linux x86-64, CPU: Intel Core i5-12450H, 3MHz, Compilier: x86-64 GCC 13.2

*Compilation*:

[Makefile](https://github.com/khmelnitskiianton/AsmCx86/blob/main/Mandelbrot/Makefile)

`make` - to compile, set `OPTIMIZE = -O3` & `NAME = /mandelbrot_opt_on` in Makefile.

`make run_opt_on`  - running with -O3

`make run_opt_off` - running with -O0

*Drawing set*:

- I draw Mandelbrot set with SDL2 on C
- Visualization has interface: &#8592;,&#8593;,&#8594;,&#8595; for moving and -,+ for zoom set. Also Window can change size.
- Press 1,2,3 while running program and see diffrent types of optimization & different fps.
- In the angle drawing actual FPS of rendering set.

*Optimiztion:*

I have 3 versions of code:

1. Naive algorithm - just processing every pixel on the screen: `DrawMandelbrot1()`
2. Algorithm using merging 8 pixel in many loops:               `DrawMandelbrot2()` 
3. Using vectorization & SIMD(AVX/AVX2):                        `DrawMandelbrot3()`

*Example of vizualization*:

<img src="https://github.com/khmelnitskiianton/AsmCx86/assets/142332024/fcca1039-4551-4c82-9f52-6b5cb45d2cb9" width=80%>

*Tests & Results*:

|Version|GCC `-O3`|FPS|
|-------|---------|---|
|   1   |   off   |8.5|
|   1   |   on    |19|
|   2   |   off   |3.5|
|   2   |   on    |25|
|   3   |   off   |24.6|
|   3   |   on    |115|

*Analysing*:

- Naive Version: GCC optimizes just algorithm on C and gives 8.5 &#8594; 19 (x2 increase). 
- Merging Version: GCC optimizes merging processing pixels using many loops and gives 3.5 &#8594; 25 (x8 increase). Comparing with naive version we get 19 &#8594; 25 (x1.3 increase). Explanation: GCC can optimize loops and process merging pixels is faster than process every pixel.
- Vectorized Version: GCC optimizes vectorization and gives 24.6 &#8594; 115 (x4.7 increase). Comparing with naive version we get with -O3 19 &#8594; 115 (x6 increase). Explanation: using vectors and SIMD can speed up processing 8 pixels in one time. GCC optimizes vectorization that gives enormous effect. Analysing `DrawMandelbrot3()` - vectorization version in [GodBolt](https://godbolt.org/) find out that -O3 minimizes amout of operations 217 &#8594; 147 by using many optimizations like changing loops to table of jumps.

*Conclusion*:

Optimization based on SIMD & Compilier optimization gives greate spped up in processing data

In drawing mandelbrot set we see how SIMD & GCC -O3 can increase FPS from 19 to 115 (x6).

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

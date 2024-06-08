# AsmCx86
Projects are writen on C+Assembler for x86-64

1. [**Mandelbrot set**](#mandelbrot-set) - vizualization of Mandelbrot set on SDL,with measuring fps and application AVX instruction for optimization(searching for speed of rendering frame)
2. [**Printf32()**](#printf32) - simple realization of printf() on NASM for x86-64

## Mandelbrot set

Project of testing optimization on Mandelbrot set visualization.

[`Main Code`](https://github.com/khmelnitskiianton/AsmCx86/blob/main/Mandelbrot/src_c/main.cpp)

**Settings:** 

- System: Linux x86-64
- CPU: Intel Core i5-12450H, 3MHz
- Compilier: x86-64 GCC 13.2

**Compilation:**

Before you need to install GCC, Make, SDL2 and SDL2_ttf - for rendering fonts

``` bash
sudo apt update && sudo apt upgrade   #update
sudo apt install build-essential      #gcc
sudo apt install make                 #make
sudo apt-get install libsdl2-dev libsdl2-ttf-dev #sdl2,sdl2_ttf
```
[`Makefile`](https://github.com/khmelnitskiianton/AsmCx86/blob/main/Mandelbrot/Makefile)

You need to have folder `./bin`, `./src_c`, `./obj`

`make` - to compile, set `OPTIMIZE = -O3` & `NAME = /mandelbrot_opt_on` in Makefile.

+ `make run_opt_on`  - running with -O3
+ `make run_opt_off` - running with -O0

**Drawing set**:

- I draw Mandelbrot set with SDL2 on C
- Visualization has interface: &#8592;,&#8593;,&#8594;,&#8595; for moving and `-`,`+` for zoom set.
- Press `1`,`2`,`3` while running program and see diffrent types of optimization & different fps.
- In the angle drawing actual FPS of rendering set.

**Example of vizualization:**

<img src="https://github.com/khmelnitskiianton/AsmCx86/assets/142332024/2bead766-15ab-4ba9-95d9-27c5e62803d2" width=80%>

**Optimiztion:**

I have 3 versions of code:

1. Naive algorithm - just processing every pixel on the screen: `DrawMandelbrot1()`

```cpp
//counting (x,y)
x = x_0;
y = y_0;
//check if (x,y) not run away from circle
size_t n = 0;
for (; n < N_MAX; n++)
{
  x2 = x * x;
  y2 = y * y;
  xy = x * y;
  r2 = (x2 + y2);
  if (r2 > r2max) 
  {
    color_flag = 1;
    break;
  }   
  x = x2 - y2 + x_0;
  y = 2 * xy  + y_0;
}
```

2. Algorithm using merging 8 pixel in many loops:               `DrawMandelbrot2()` 

```cpp
//counting (x,y)
for (size_t i = 0; i < SIZE; i++) color_flag[i] = 0;
for (size_t i = 0; i < SIZE; i++) x_0_arr[i] = x_0 + dx*((float)i)*(*scale);
for (size_t i = 0; i < SIZE; i++) x[i] = x_0_arr[i];
for (size_t i = 0; i < SIZE; i++) y[i] = y_0;
//check if (x,y) not run away from circle
size_t n[SIZE] = {0,0,0,0};
for (size_t m = 0; m < N_MAX; m++)
{
    int cmp[SIZE] = {0,0,0,0};
    for (size_t k = 0; k < SIZE; k++)    x2[k] = x[k] * x[k];
    for (size_t k = 0; k < SIZE; k++)    y2[k] = y[k] * y[k];
    for (size_t k = 0; k < SIZE; k++)    xy[k] = x[k] * y[k];
    for (size_t k = 0; k < SIZE; k++)    r2[k] = (x2[k] + y2[k]);
    for (size_t k = 0; k < SIZE; k++) if (r2[k] <= r2max) cmp[k] = 1;
    for (size_t k = 0; k < SIZE; k++) if (r2[k] > r2max)  color_flag[k] = 1;
    mask = 0; 
    for (size_t k = 0; k < SIZE; k++) mask |= (cmp[k] << k);
    if (!mask) break;
    for (size_t k = 0; k < SIZE; k++) n[k] = n[k] + (size_t)cmp[k];
    for (size_t k = 0; k < SIZE; k++) x[k] = x2[k] - y2[k] + x_0_arr[k];
    for (size_t k = 0; k < SIZE; k++) y[k] = 2 * xy[k]     + y_0;
}  
```

3. Using vectorization & SIMD(AVX/AVX2):                        `DrawMandelbrot3()`

```cpp
//counting (x,y)
__m256 x_0_arr = _mm256_add_ps (_mm256_set1_ps (x_0), _mm256_mul_ps (_76543210, _mm256_set1_ps (dx*(*scale))));
__m256 y_0_arr =                                                    _mm256_set1_ps (y_0);
__m256 x = x_0_arr; 
__m256 y = y_0_arr;
__m256i n = _mm256_setzero_si256();
__m256 cmp = _mm256_setzero_ps();
for (size_t m = 0; m < N_MAX; m++)
{
    __m256 x2 = _mm256_mul_ps (x, x);
    __m256 y2 = _mm256_mul_ps (y, y);
    __m256 xy = _mm256_mul_ps (x, y);
    __m256 r2 = _mm256_add_ps (x2,y2);
    cmp = _mm256_cmp_ps (r2, r2max, _CMP_LE_OS);
    int mask = 0; 
    mask = _mm256_movemask_ps (cmp);
    if (!mask) break;
    n = _mm256_sub_epi32 (n, _mm256_castps_si256(cmp)); 
    x = _mm256_add_ps (_mm256_sub_ps(x2,y2), x_0_arr);
    y = _mm256_add_ps (_mm256_add_ps(xy,xy), y_0_arr);
} 
```

**Tests & Results:**

|Version|GCC `-O3`|FPS|
|-------|---------|---|
|   1   |   off   |8.5|
|   1   |   on    |19|
|   2   |   off   |3.5|
|   2   |   on    |25|
|   3   |   off   |24.6|
|   3   |   on    |115|

**Analysing:**

- Naive Version: GCC optimizes just algorithm on C and gives 8.5 &#8594; 19 (x2 increase). 
- Merging Version: GCC optimizes merging processing pixels using many loops and gives 3.5 &#8594; 25 (x8 increase). Comparing with naive version we get 19 &#8594; 25 (x1.3 increase). Explanation: GCC can optimize loops and process merging pixels is faster than process every pixel.
- Vectorized Version: GCC optimizes vectorization and gives 24.6 &#8594; 115 (x4.7 increase). Comparing with naive version we get with -O3 19 &#8594; 115 (x6 increase). Explanation: using vectors and SIMD can speed up processing 8 pixels in one time. GCC optimizes vectorization that gives enormous effect. Analysing `DrawMandelbrot3()` - vectorization version in [GodBolt](https://godbolt.org/) find out that -O3 minimizes amout of operations 217 &#8594; 147 by using many optimizations like changing loops to table of jumps.

**Conclusion:**

Optimization based on SIMD & Compilier optimization gives greate spped up in processing data

In drawing mandelbrot set we see how SIMD & GCC -O3 can increase FPS from 19 to 115 (x6)!

## Printf32

Simple version of printf() on NASM on Linux x86-64:

[```Printf32.nasm```](https://github.com/khmelnitskiianton/AsmCx86/blob/main/Printf32/src_asm/printf32.nasm)

[```lib.inc```](https://github.com/khmelnitskiianton/AsmCx86/blob/main/Printf32/src_asm/lib.inc)

**Specifiers:**

+ `%c` - char symbol
+ `%s` - string
+ `%d` - signed integer number(32-byte)
+ `%u` - unsigned integer number(64-byte)
+ `%o` - octal integer number(64-byte)
+ `%x` - hexiamal integer number(64-byte)
+ `%b` - binary integer number(64-byte)
+ `%p` - pointer address in hex(64-byte)
+ `%n` - writes in address the number of characters outputted so far (32-byte)

**Options:**
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

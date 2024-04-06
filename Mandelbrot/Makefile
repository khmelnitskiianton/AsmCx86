SRC_C_EXT 	= .cpp

INTRINCS = -msse4.1 -msse4.2 -mavx2 -mavx
OPTIMIZE = -O3

NAME	= /mandelbrot_opt_on

LDFLAGS = -lSDL2 -lSDL2_ttf
CFLAGS = -I/usr/include/SDL2 -D_REENTRANT $(INTRINCS) $(OPTIMIZE)

SRC_ASM = ./src_asm
SRC_C   = ./src_c
OBJ     = ./obj
BIN     = ./bin
OUT     = $(BIN)
NAME1   = /mandelbrot_opt_on
NAME2   = /mandelbrot_opt_off

SOURCES_C 		= $(SRC_C)/main.cpp
OBJFILES_C		= $(patsubst $(SRC_C)/%,$(OBJ)/%,$(SOURCES_C:$(SRC_C_EXT)=.o))

$(OUT)$(NAME): $(OBJFILES_C)	#Linking with GCC use -no-pie
	g++ $^ $(OPTIMIZE) $(LDFLAGS) -o $@

$(OBJ)/%.o : $(SOURCES_C)		#Object with GCC use -O3
	g++ $(OPTIMIZE) $(CFLAGS) -c -o $@ $<

.PHONY: clean
clean:
	rm -f $(OBJ)/*.o

.PHONY: run
run_opt_on:
	$(OUT)$(NAME1)	
run_opt_off:
	$(OUT)$(NAME2)	
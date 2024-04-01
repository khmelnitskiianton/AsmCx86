SRC_C_EXT 	= .cpp

INTRINCS = -msse4.1 -msse4.2 -mavx2 -mavx
OPTIMIZE = -O0

LDFLAGS = -lSDL2 -lSDL2_ttf
CFLAGS = -I/usr/include/SDL2 -D_REENTRANT $(INTRINCS) $(OPTIMIZE)

SRC_ASM = ./src_asm
SRC_C   = ./src_c
OBJ     = ./obj
BIN     = ./bin
OUT     = $(BIN)
NAME	= /mb2_no_opt_on_avx

SOURCES_C 		= $(SRC_C)/main2.cpp
OBJFILES_C		= $(patsubst $(SRC_C)/%,$(OBJ)/%,$(SOURCES_C:$(SRC_C_EXT)=.o))

$(OUT)$(NAME): $(OBJFILES_C)	#Linking with GCC use -no-pie
	g++ $^ $(OPTIMIZE) $(LDFLAGS) -o $@

$(OBJ)/%.o : $(SOURCES_C)		#Object with GCC use -O3
	g++ $(OPTIMIZE) $(CFLAGS) -c -o $@ $<

.PHONY: clean
clean:
	rm -f $(OBJ)/*.o

.PHONY: run
run:
	$(OUT)$(NAME)	
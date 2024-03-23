SRC_ASM_EXT = .nasm
SRC_C_EXT 	= .cpp

CFLAGS = -D _DEBUG -ggdb3 -std=c++17 -Wall -Wextra -Weffc++ -Waggressive-loop-optimizations -Wc++14-compat -Wmissing-declarations -Wcast-align -Wcast-qual -Wchar-subscripts -Wconditionally-supported -Wconversion -Wctor-dtor-privacy -Wempty-body -Wfloat-equal -Wformat-nonliteral -Wformat-security -Wformat-signedness -Wformat=2 -Winline -Wlogical-op -Wnon-virtual-dtor -Wopenmp-simd -Woverloaded-virtual -Wpacked -Wpointer-arith -Winit-self -Wredundant-decls -Wshadow -Wsign-conversion -Wsign-promo -Wstrict-null-sentinel -Wstrict-overflow=2 -Wsuggest-attribute=noreturn -Wsuggest-final-methods -Wsuggest-final-types -Wsuggest-override -Wswitch-default -Wswitch-enum -Wsync-nand -Wundef -Wunreachable-code -Wunused -Wuseless-cast -Wvariadic-macros -Wno-literal-suffix -Wno-missing-field-initializers -Wno-narrowing -Wno-old-style-cast -Wno-varargs -Wstack-protector -fcheck-new -fsized-deallocation -fstack-protector -fstrict-overflow -flto-odr-type-merging -fno-omit-frame-pointer -Wlarger-than=20000 -Wstack-usage=20000 -pie -fPIE -Werror=vla -fsanitize=address,alignment,bool,bounds,enum,float-cast-overflow,float-divide-by-zero,integer-divide-by-zero,leak,nonnull-attribute,null,object-size,return,returns-nonnull-attribute,shift,signed-integer-overflow,undefined,unreachable,vla-bound,vptr
INTRINCS = -msse2 -mavx
OPTIMIZE = -O3

SRC_ASM = ./src_asm
SRC_C   = ./src_c
OBJ     = ./obj
BIN     = ./bin
OUT     = $(BIN)
NAME	= /mb3_on_opt_on_avx

SOURCES_ASM 	= $(wildcard $(SRC_ASM)/*$(SRC_ASM_EXT))
SOURCES_C		= $(wildcard $(SRC_C)/*$(SRC_C_EXT))

OBJFILES_ASM    = $(patsubst $(SRC_ASM)/%,$(OBJ)/%,$(SOURCES_ASM:$(SRC_ASM_EXT)=.o))
OBJFILES_C		= $(patsubst $(SRC_C)/%,$(OBJ)/%,$(SOURCES_C:$(SRC_C_EXT)=.o))

$(OUT)$(NAME): $(OBJFILES_C)	#Linking with GCC use -no-pie
	gcc $(OPTIMIZE) $(INTRINCS) -I/home/anton/lib/freetype2/include/SDL2 `sdl2-config --cflags --libs` -lSDL2 -lSDL2_ttf  $(CFLAGS) $^ -o $@ -lm

$(OBJ)/%.o : $(SRC_C)/%$(SRC_C_EXT)				#Object with GCC use -O3
	gcc $(OPTIMIZE) $(INTRINCS) -I/home/anton/lib/freetype2/include/SDL2 `sdl2-config --cflags --libs` -lSDL2 -lSDL2_ttf $(CFLAGS) -c -o $@ $< -lm

.PHONY: clean
clean:
	rm -f $(OBJ)/*.o

.PHONY: run
run:
	$(OUT)$(NAME)	
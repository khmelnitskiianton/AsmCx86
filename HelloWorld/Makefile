SRC_ASM_EXT = .nasm
SRC_C_EXT 	= .cpp

SRC_ASM = ./src_asm
SRC_C   = ./src_c
OBJ     = ./obj
BIN     = ./bin
OUT     = $(BIN)
NAME	= /program

SOURCES_ASM 	= $(wildcard $(SRC_ASM)/*$(SRC_ASM_EXT))
SOURCES_C		= $(wildcard $(SRC_C)/*$(SRC_C_EXT))

OBJFILES_ASM    = $(patsubst $(SRC_ASM)/%,$(OBJ)/%,$(SOURCES_ASM:$(SRC_ASM_EXT)=.o))
OBJFILES_C		= $(patsubst $(SRC_C)/%,$(OBJ)/%,$(SOURCES_C:$(SRC_C_EXT)=.o))

$(OUT)$(NAME): $(OBJFILES_ASM) $(OBJFILES_C)	#Linking with GCC use -no-pie
	gcc $^ -o $@ -no-pie					

$(OBJ)/%.o : $(SRC_ASM)/%$(SRC_ASM_EXT)			#Assemble with NASM -f elf64
	nasm -f elf64 -l $@.lst $< -o $@

$(OBJ)/%.o : $(SRC_C)/%$(SRC_C_EXT)				#Object with GCC use -O3
	gcc -O3 -c -o $@ $<

.PHONY: clean
clean:
	rm -f $(OUT)/* $(OBJ)/*.o $(OBJ)/*.lst

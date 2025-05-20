# Compiler and Assembler
CC = gcc
NASM = nasm

# Compiler and Assembler flags
# -Wall: Enable all warnings
# -O0: No optimization (de-optimized for comparison)
# -g: Add debugging information
CFLAGS = -Wall -O0 -g # Changed -O2 to -O0
NASMFLAGS = -f elf64 -g

# Linker flags
# -no-pie: If linking non-PIC assembly or encountering issues
LDFLAGS = -no-pie
LDLIBS = # -lrt (Uncomment if clock_gettime issues)

# Target executable name
TARGET = main_tester

# Source files
C_SOURCES = main.c
ASM_SOURCES = asm_libraary.asm # Assuming this is your assembly file name

# Object files
C_OBJECTS = $(C_SOURCES:.c=.o)
ASM_OBJECTS = $(ASM_SOURCES:.asm=.o)

# Default target: Build all
all: $(TARGET)

# Rule to link the target executable
$(TARGET): $(C_OBJECTS) $(ASM_OBJECTS)
	$(CC) $(LDFLAGS) $^ -o $@ $(LDLIBS)
	@echo "Linking complete. Executable '$(TARGET)' created."

# Rule to compile C source files to object files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
	@echo "Compiled $< to $@."

# Rule to assemble NASM source files to object files
%.o: %.asm
	$(NASM) $(NASMFLAGS) $< -o $@
	@echo "Assembled $< to $@."

# Target to clean up generated files
clean:
	rm -f $(TARGET) $(C_OBJECTS) $(ASM_OBJECTS)
	@echo "Cleaned up object files and executable."

# Phony targets
.PHONY: all clean info

info:
	@echo "Makefile for C and Assembly project"
	@echo "Targets:"
	@echo "  all    : Build the $(TARGET) executable (default)"
	@echo "  clean  : Remove all generated object files and the executable"
	@echo "Usage:"
	@echo "  make         (or make all)"
	@echo "  make clean"

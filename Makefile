ASMFILES = $(wildcard *.asm)
BINS := $(patsubst %.asm,%.bin,$(wildcard *.asm))

all: ${BINS}

boot:
	qemu-system-x86_64 ttt.bin

%.bin: %.asm
	nasm -f bin $< -o $@

boot_debug:
	qemu-system-i386 -fda ttt.bin -boot a -s -S

gdb:
	gdb --init-command=.gdbinit

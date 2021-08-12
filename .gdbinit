target remote localhost:1234

set architecture i8086
layout asm
tui reg general

# info win
#fs reg or asm or cmd
fs cmd


br *0x7c00

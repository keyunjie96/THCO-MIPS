.global __start
.set noat
__start:
    lui $3, 0xbfc0
    ori $3, $3, 0x100
    ori $1, $0, 0x1234
    sw $1, 0x0($3)
    ori $2, $0, 0x1234
    ori $1, $0, 0x0
    lw $1, 0x0($3)
    beq $1, $2, label
    ori $1, $0, 4567
    nop
label:
    ori $1, $0, 0x89ab
    nop
loop:
    j loop

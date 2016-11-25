.global __start
.set noat
__start:
    lui $2, 0xbfc0
    ori $2, 0x20
    jalr $2
    jal func
    j next
func:
    jr $31
end:
    j end
next:
    lui $1, 0xffff
    ori $1, 0xfffd
    lui $2, 0x0
loop:
    addiu $1, $1, 0x1
    beq $1, $2, end
    j loop
.global __start
.set noat
__start:
    lui $1, 0x9fd0
    ori $1, 0x03f8
    ori $2, $0, 0x68
    sw $2, 0x0($1)
    ori $2, $0, 0x65
    sw $2, 0x0($1)
    ori $2, $0, 0x6c
    sw $2, 0x0($1)
    ori $2, $0, 0x6c
    sw $2, 0x0($1)
    ori $2, $0, 0x6f
    sw $2, 0x0($1)
    ori $2, $0, 0x20
    sw $2, 0x0($1)
    ori $2, $0, 0x77
    sw $2, 0x0($1)
    ori $2, $0, 0x6f
    sw $2, 0x0($1)
    ori $2, $0, 0x72
    sw $2, 0x0($1)
    ori $2, $0, 0x6c
    sw $2, 0x0($1)
    ori $2, $0, 0x64
    sw $2, 0x0($1)
    ori $2, $0, 0x21
    sw $2, 0x0($1)
    ori $2, $0, 0x0a
    sw $2, 0x0($1)
loop:
    b loop

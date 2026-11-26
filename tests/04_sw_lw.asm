# NUEVO test corto. SW y LW en direccion 0x300, lejos del codigo.
.text
.globl main
main:
    addiu $t0, $zero, 68
    sw    $t0, 0x300($zero)
    lw    $a0, 0x300($zero)
    addiu $v0, $zero, 11
    syscall
    addiu $v0, $zero, 10
    syscall

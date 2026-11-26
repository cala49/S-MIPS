# NUEVO test corto. BNE tomado y no tomado (salto atras); BEQ no tomado y tomado; J.
.text
.globl main
main:
    addiu $t0, $zero, 0
    addiu $t1, $zero, 3
bucle:
    addiu $t0, $t0, 1
    addiu $t1, $t1, -1
    bne   $t1, $zero, bucle
    beq   $t0, $zero, error
    beq   $t0, $t0, bien
error:
    addiu $t0, $zero, 9
bien:
    j     salida
    addiu $t0, $zero, 8
salida:
    addiu $a0, $t0, 48
    addiu $v0, $zero, 11
    syscall
    addiu $v0, $zero, 10
    syscall

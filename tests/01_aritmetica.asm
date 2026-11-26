# NUEVO test corto. ADDI(+), ADDIU(-), ADD, SUB, ADDU; operandos negativos.
.text
.globl main
main:
    addi  $t0, $zero, 9
    addiu $t1, $zero, -4
    add   $t2, $t0, $t1
    sub   $t3, $t0, $t2
    addu  $a0, $t3, $t2
    addi  $a0, $a0, 44
    addiu $v0, $zero, 11
    syscall
    addiu $v0, $zero, 10
    syscall

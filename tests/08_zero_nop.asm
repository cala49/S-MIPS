# NUEVO test corto. $zero inmutable ante ADDIU; NOP (SLL $zero,$zero,0).
.text
.globl main
main:
    addiu $zero, $zero, 7
    sll   $zero, $zero, 0
    addiu $a0, $zero, 90
    addiu $v0, $zero, 11
    syscall
    addiu $v0, $zero, 10
    syscall

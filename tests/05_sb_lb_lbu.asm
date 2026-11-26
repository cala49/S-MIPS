# NUEVO test corto. SB en carril 3; LB signo bit7=1; LBU extension con ceros.
.text
.globl main
main:
    addiu $t0, $zero, 0x80
    sb    $t0, 0x303($zero)
    lb    $t1, 0x303($zero)
    lbu   $t2, 0x303($zero)
    addu  $t3, $t1, $t2
    addiu $a0, $t3, 69
    addiu $v0, $zero, 11
    syscall
    addiu $v0, $zero, 10
    syscall

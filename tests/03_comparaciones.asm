# NUEVO test corto. SLT y SLTI con operando negativo; AND, OR, SLL != 0.
.text
.globl main
main:
    addiu $t0, $zero, -2
    addiu $t1, $zero, 3
    slt   $t2, $t0, $t1
    slti  $t3, $t0, 0
    and   $t4, $t2, $t3
    or    $t5, $t4, $t2
    sll   $a0, $t5, 1
    addiu $a0, $a0, 65
    addiu $v0, $zero, 11
    syscall
    addiu $v0, $zero, 10
    syscall

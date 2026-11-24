# Prueba propia S-MIPS: beq, bne y j.
# Salida esperada en TTY: OK\n
.text
.globl main
main:
    addiu $t0, $zero, 5
    addiu $t1, $zero, 5
    beq   $t0, $t1, equal
    j fail

equal:
    addiu $t1, $zero, 6
    bne   $t0, $t1, different
    j fail

different:
    beq   $t0, $t1, fail
    bne   $t0, $t0, fail
    j success

success:
    addiu $a0, $zero, 79
    addiu $v0, $zero, 11
    syscall
    addiu $a0, $zero, 75
    syscall
    addiu $a0, $zero, 10
    syscall
    j exit

fail:
    addiu $a0, $zero, 70
    addiu $v0, $zero, 11
    syscall
    addiu $a0, $zero, 65
    syscall
    addiu $a0, $zero, 73
    syscall
    addiu $a0, $zero, 76
    syscall
    addiu $a0, $zero, 10
    syscall

exit:
    addiu $v0, $zero, 10
    syscall

# Prueba propia S-MIPS: memoria, carriles de byte, extension con signo.
# Salida esperada en TTY: OK\n
.data
word0: .word 0
.text
.globl main
main:
    addiu $t0, $gp, 0x800    # .data comienza en 0x2000; $gp = 0x1800
    addiu $t1, $zero, 42
    sw    $t1, 0($t0)
    lw    $t2, 0($t0)
    bne   $t1, $t2, fail

    addiu $t3, $zero, -1
    sb    $t3, 1($t0)
    lbu   $t4, 1($t0)
    addiu $t5, $zero, 255
    bne   $t4, $t5, fail
    lb    $t4, 1($t0)
    bne   $t4, $t3, fail

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

# Prueba propia S-MIPS: operaciones aritmeticas y logicas.
# Salida esperada en TTY: OK\n
.text
.globl main
main:
    addiu $t0, $zero, 7
    addiu $t1, $zero, 3
    addu  $t2, $t0, $t1      # 10
    addiu $t3, $zero, 10
    bne   $t2, $t3, fail

    sub   $t2, $t0, $t1      # 4
    addiu $t3, $zero, 4
    bne   $t2, $t3, fail

    and   $t2, $t0, $t1      # 7 & 3 = 3
    bne   $t2, $t1, fail

    or    $t2, $t0, $t1      # 7 | 3 = 7
    bne   $t2, $t0, fail

    slt   $t2, $t1, $t0      # 3 < 7
    addiu $t3, $zero, 1
    bne   $t2, $t3, fail

    addiu $a0, $zero, 79    # O
    addiu $v0, $zero, 11
    syscall
    addiu $a0, $zero, 75    # K
    syscall
    addiu $a0, $zero, 10    # \n
    syscall
    j exit

fail:
    addiu $a0, $zero, 70    # F
    addiu $v0, $zero, 11
    syscall
    addiu $a0, $zero, 65    # A
    syscall
    addiu $a0, $zero, 73    # I
    syscall
    addiu $a0, $zero, 76    # L
    syscall
    addiu $a0, $zero, 10
    syscall

exit:
    addiu $v0, $zero, 10
    syscall

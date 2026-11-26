# NUEVO test corto. LUI, ORI y ANDI con bit15 del inmediato = 1; SRL y ADDU.
.text
.globl main
main:
    lui   $t0, 0x0041
    ori   $t0, $t0, 0x8042
    andi  $t1, $t0, 0x8000
    srl   $t1, $t1, 15
    srl   $a0, $t0, 16
    addu  $a0, $a0, $t1
    addiu $v0, $zero, 11
    syscall
    addiu $v0, $zero, 10
    syscall

# NUEVO test corto. JAL guarda retorno en $ra; JR vuelve al llamador.
.text
.globl main
main:
    jal   construir
    addiu $a0, $t0, 48
    addiu $v0, $zero, 11
    syscall
    addiu $v0, $zero, 10
    syscall
construir:
    addiu $t0, $zero, 7
    jr    $ra

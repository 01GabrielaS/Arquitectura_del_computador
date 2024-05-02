
.data
base:       .word   5
exp:        .word   3   
result:     .word   0

result_msg: .asciiz "El resultado es: "
error_msg:  .asciiz "Error: Base o exponente no válidos"


.text
.globl  main
main:
    lw  $a0, base          # Carga la base en $a0
    lw  $a1, exp           # Carga el exponente en $a1

    # Verificar si la base es 0
    beq $a0, $zero, base_zero
    
    # Verificar si el exponente es 0
    beq $a1, $zero, exp_zero

    # Verificar si la base o el exponente son negativos
    bltz $a0, error
    bltz $a1, error

    # Calcular la potencia
    jal potencia                
    sw  $v0, result         # Guarda $v0 a result 
    j print_result

base_zero:
    li $v0, 0               # Si la base es 0, el resultado es 0
    sw $v0, result
    j print_result

exp_zero:
    li $v0, 1               # Si el exponente es 0, el resultado es 1
    sw $v0, result
    j print_result

error:
    # Imprimir mensaje de error
    li $v0, 4
    la $a0, error_msg
    syscall

    # Salir del programa
    li $v0, 10
    syscall

print_result:
    li  $v0, 4               
    la  $a0, result_msg     
    syscall                

    # Imprime el resultado
    li  $v0, 1               
    lw  $a0, result         
    syscall                
    
    li  $v0, 10             # Llama al código para salir
    syscall                 



#   función potencia:
#    $a0 = base
#    $a1 = exponente
#    return:   $v0 = base^exp


.globl  potencia
potencia:  
        add   $t0,$zero,$zero   # Inicializa $t0 = 0, $t0 registra cuántas se hace la op. multiplicación
        li $v0, 1               # Valor inicial de resultado a 1
potencia_loop: beq $t0, $a1, exit_L    
        mul $v0,$v0,$a0         
        addi $t0,$t0,1          
        j   power_loop
        
exit_L:     jr  $ra

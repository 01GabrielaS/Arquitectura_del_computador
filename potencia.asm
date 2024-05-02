# Power program
# ----------------------------------
# Data Segment
.data
base:       .word   5
exp:        .word   3   
result:     .word   0

result_msg: .asciiz "El resultado es: "
error_msg:  .asciiz "Error: Base o exponente inválidos\n"

# ----------------------------------
# Text/Code Segment

.text
.globl  main
main:
    lw  $a0, base          # Carga la palabra var_x en la memoria a $a0
    lw  $a1, exp           # Carga la palabra var_y en la memoria a $a1

    # Verificar si la base es 0
    beq $a0, $zero, base_zero
    
    # Verificar si el exponente es 0
    beq $a1, $zero, exp_zero

    # Verificar si la base o el exponente son negativos
    bltz $a0, error
    bltz $a1, error

    # Si ninguno de los casos anteriores, calcular la potencia
    jal potencia             # Llama a la función power   
    sw  $v0, result         # Guarda la palabra desde $v0 a result en la memoria
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
    # Imprime el mensaje de resultado
    li  $v0, 4               # Llama al código para imprimir cadena
    la  $a0, result_msg     # Carga la dirección de la cadena a imprimir en $a0
    syscall                 # Llamar a la syscall

    # Imprime el resultado
    li  $v0, 1               # Llama al código para imprimir entero
    lw  $a0, result         # Cargar el resultado desde la memoria a imprimir en $a0
    syscall                 # Llamar a la syscall

    # Done, exit program.
    li  $v0, 10             # Llama al código para salir
    syscall                 # Llamada al sistema

# ----------------------------------
#   power
# arguments:    $a0 = x
#       $a1 = y
# return:   $v0 = x^y
# ----------------------------------

.globl  potencia
potencia:  
        add   $t0,$zero,$zero   # Inicializa $t0 = 0, $t0 se utiliza para registrar cuántas veces hacemos las operaciones de multiplicación
        li $v0, 1               # Establece el valor inicial de $v0 = 1
potencia_loop: beq $t0, $a1, exit_L    
        mul $v0,$v0,$a0         # Multiplica $v0 y $a0 en $v0 
        addi $t0,$t0,1          # Actualiza el valor de $t0   
        j   power_loop
        
exit_L:     jr  $ra



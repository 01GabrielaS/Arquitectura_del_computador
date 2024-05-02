	.data

str_enter_multiplicand:		.asciiz "\nMultiplicando : "
str_enter_multiplier:		.asciiz "\nMultiplicador: "
str_print_00_info:		.asciiz "00, deaplazamiento sin cambio"
str_print_01_info:		.asciiz "01, suma y desplazamiento"
str_print_10_info:		.asciiz "10, subtract shift"
str_print_11_info:		.asciiz "11, nop shift"
str_print_result:		.asciiz "\n\nResultado -> [(U, V) del Paso=32]: "
str_loop_counter:		.asciiz "\nPaso="
str_tab:			.asciiz "\t"
str_n:				.asciiz "N="
str_u:				.asciiz "U="
str_v:				.asciiz "V="
str_x:				.asciiz "X="
str_y:				.asciiz "Y="
str_x_1:			.asciiz "X-1="


# 	Syscall variables
#	-----------------
print_int: .word 1
print_bin: .word 35
print_str: .word 4
leer_int: .word 5
salir: .word 10

	.text
	.globl main

main:
	# inicializa el contador  = 0, U=0, V=0, X-1=0, N=0 
	addi $s0, $zero, 0
	addi $s3, $zero, 0
	addi $s4, $zero, 0
	addi $s5, $zero, 0
	addi $s6, $zero, 0

	# ask for multiplier
	lw   $v0, print_str
	la   $a0, str_enter_multiplier
	syscall

	# get integer into $s1
	lw   $v0, leer_int
	syscall
	add  $s1, $zero, $v0

	# ask for multiplicand
	lw   $v0, print_str
	la   $a0, str_enter_multiplicand
	syscall

	# get integer into $s2
	lw   $v0, leer_int
	syscall
	add  $s2, $zero, $v0


#	Imprime los estados de la última etapa del algoritmo

print_step:

	# verifica el contador del loop
	beq  $s0, 33, exit

	# N° de paso
	lw   $v0, print_str
	la   $a0, str_loop_counter
	syscall

	# Imprime el paso
	lw   $v0, print_int
	add  $a0, $zero, $s0
	syscall
	lw   $v0, print_str
	la   $a0, str_tab
	syscall

	# "N"
	lw   $v0, print_str
	la   $a0, str_n
	syscall

	# N
	lw   $v0, print_int
	add  $a0, $zero, $s6
	syscall
	lw   $v0, print_str
	la   $a0, str_tab
	syscall

	# "U"
	lw   $v0, print_str
	la   $a0, str_u
	syscall

	# valor de U
	lw   $v0, print_bin
	add  $a0, $zero, $s3
	syscall
	lw   $v0, print_str
	la   $a0, str_tab
	syscall

	# "V"
	lw   $v0, print_str
	la   $a0, str_v
	syscall

	# valor de V
	lw   $v0, print_bin
	add  $a0, $zero, $s4
	syscall
	lw   $v0, print_str
	la   $a0, str_tab
	syscall

	# "X"
	lw   $v0, print_str
	la   $a0, str_x
	syscall

	# valor de X
	lw   $v0, print_bin
	add  $a0, $zero, $s1
	syscall
	lw   $v0, print_str
	la   $a0, str_tab
	syscall

	# "X-1"
	lw   $v0, print_str
	la   $a0, str_x_1
	syscall

	# Imprime X-1
	lw   $v0, print_int
	add  $a0, $zero, $s5
	syscall
	lw   $v0, print_str
	la   $a0, str_tab
	syscall


#	evalua los valores de dos bits de $s1 -multiplicador "X"-
	
	andi $t0, $s1, 1		# LSB de X
	beq  $t0, $zero, x_lsb_0	# if ($t0 == 0)->x_lsb_0
	j    x_lsb_1			# if ($t1 == 1)->x_lsb_1

x_lsb_0: 				#cuando el LSB de X=0
	beq  $s5, $zero, caso_00	# if (X-1 == 0)  caso_00
	j    caso_01			# if (X-1 == 1)  caso01

x_lsb_1:				# cuando el  LSB de  X = 1  
	beq  $s5, $zero, caso_10	# si (X-1 == 0) ir al caso 10
	j    caso_11			# si (X-1 == 0) ir al caso 11

caso_00:
	# imprimir info
	lw   $v0,print_str
	la   $a0, str_print_00_info
	syscall
	# shifting
	andi $t0, $s3, 1		# LSB de U
	bne  $t0, $zero, V		# Si LSB!=0 salta a V
	srl  $s4, $s4, 1		# corrimeinto logico de V
	j    shift			

caso_01:
	#imprimir info
	lw   $v0, print_str
	la   $a0, str_print_01_info
	syscall

	# el multiplicador es el numero negativo más grande en C2?
	beq  $s2, -2147483648, do_special_add

	# suma y shifting
	add  $s3, $s3, $s2		# U+=Y
	andi $s5, $s5, 0		# X=0, ->-1=0
	andi $t0, $s3, 1		# LSB de U es 0?
	bne  $t0, $zero, V		# Si no, existe overflow y salta a V ($s4)
	srl  $s4, $s4, 1		# Corrimiento lógico a la derecha 
	j    shift			# salta a shift para el corrimiento de las otras variables

caso_10:
	# imprimir info
	lw   $v0, print_str
	la   $a0, str_print_10_info
	syscall
	
	# el multiplicador es el numero negativo más grande en C2?
	beq  $s2, -2147483648, do_special_sub

	# resta y shifting
	sub  $s3, $s3, $s2		# U-=Y
	ori  $s5, $s5, 1		# X=1, ->X-1=1
	andi $t0, $s3, 1		# verifica el LSB de U 
	bne  $t0, $zero, V		#  Si el LSB de U no es cero, salta a V
	srl  $s4, $s4, 1		# Corrimiento lógico a la derecha 
	j    shift			# salta a shift para el corrimiento de las otras variables

caso_11:
	# imprimir info
	lw   $v0, print_str
	la   $a0, str_print_11_info
	syscall
	# shifting
	andi $t0, $s3, 1		# verifica el LSB de U 
	bne  $t0, $zero, V		# Si el LSB de U no es cero, salta a update
	srl  $s4, $s4, 1		# Corrimiento lógico a la derecha 
	j    shift 			# salta a shift para el corrimiento de las otras variables

V:
	andi $t0, $s4, 0x80000000	#  MSB de V
	bne  $t0, $zero, v_msb_1	# Si MSB == 1, salta a v_msb_1
	srl  $s4, $s4, 1		# Si MSB == 0,  realiza corriiento a la derecha de V
	ori  $s4, $s4, 0x80000000	# MSB of V = 1
	j    shift			

v_msb_1:
	srl  $s4, $s4, 1		# realiza corriiento a la derecha de V
	ori  $s4, $s4, 0x80000000	# MSBde V=1
	j    shift			

shift:
	sra  $s3, $s3, 1		# corrimiento aritmetico a la der. de U
	ror  $s1, $s1, 1		# rotación a la derecha 
	addi $s0, $s0, 1		# decremento del contador del loop
	beq  $s0, 32, save		# si el contador está en el último paso salta a save
	j    print_step		

save:
	add  $t1, $zero, $s3		# guarda U en $t1
	add  $t2, $zero, $s4		# guarda V en $t2
	j    print_step			# loop


#	 cuando el multiplicando es el número negativo más grande 
	

do_special_sub:				#  agrega la variable N como MSB de U
	subu $s3, $s3, $s2		# U-=Y
	andi $s6, $s6, 0		# N=0
	ori  $s5, $s5, 1		# X=1, ->X-1=1
	andi $t0, $s3, 1		# LSB de U
	bne  $t0, $zero, V		# si LSB de U !=0 salta a V
	srl  $s4, $s4, 1		# corriemiento lógico a la derecha
	j    shift_special		# salta a shift especial, verifica N para actualizar U

do_special_add:				# agregar variable N como MSB de U
	addu $s3, $s3, $s2		# suma Y a U
	ori  $s6, $s6, 1		#  N=1
	andi $s5, $s5, 0		# X=0, ->X-1=0
	andi $t0, $s3, 1		# LSB de U
	bne  $t0, $zero, V		
	srl  $s4, $s4, 1		
	j    shift_special		
	
	
shift_special:
	beq  $s6, $zero, n_0	# if (N==0)  ir a n_0
	sra  $s3, $s3, 1		# dezplazamiento aritmetico de U
	ror  $s1, $s1, 1		# rotar X a la derecha
	addi $s0, $s0, 1		# decrementa el contador
	beq  $s0, 32, save		# isi es el ultimo paso, guarda el contenido de los registros
	j    print_step		

n_0:
	srl  $s3, $s3, 1		# desplazamiento de U a la derecha 
	ror  $s1, $s1, 1		# desplazar X a la derecha
	addi $s0, $s0, 1		# decremeta el contador
	beq  $s0, 32, save		# si es el último paso, guarda el contenido
	j    print_step			# vuelve a iterar




exit:
	#Imprime resultado
	lw   $v0, print_str
	la   $a0, str_print_result
	syscall
	
	# Llama  a U
	lw   $v0, print_bin
	add  $a0, $zero, $t1
	syscall
	# Llama a V
	lw   $v0, print_bin
	add  $a0, $zero, $t2
	syscall
	
	# Salir
	lw   $v0, salir
	syscall

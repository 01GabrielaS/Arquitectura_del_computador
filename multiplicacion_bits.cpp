#include <iostream>
#include <bitset>
#include <cstring>
using namespace std;

bitset<sizeof(float) * 8> numero_repr_iee(float valor){
    // Convertir el valor float a su representación en formato IEEE 754
    unsigned int valor_ieee754;
    std::memcpy(&valor_ieee754, &valor, sizeof(float));
    // Crear un objeto bitset para almacenar la representación en binario
    bitset<sizeof(float) * 8> bits_valor(valor_ieee754);
    return bits_valor;
}

// Función para sumar dos objetos bitset de 9 bits
std::bitset<9> sumarBitsets(const std::bitset<9>& bits1, const std::bitset<9>& bits2) {
    std::bitset<9> suma;
    bool carry = false; // Variable para almacenar el carry (acarreo)

    for (int i = 0; i < 9; ++i) {
        suma[i] = bits1[i] ^ bits2[i] ^ carry; // Suma bit a bit, considerando el carry
        carry = (bits1[i] & bits2[i]) | (bits1[i] & carry) | (bits2[i] & carry); // Actualizar el carry
    }

    return suma;
}

// Función para calcular el complemento a 2 de un número en formato binario
std::bitset<9> complementoA2(const std::bitset<9>& numero) {
    std::bitset<9> complemento;
    bool carry = true; // Inicializar el carry en true para la suma de 1 al final

    for (int i = 0; i < 9; ++i) {
        complemento[i] = !numero[i] ^ carry; // Aplicar la operación NOT XOR con el carry
        carry = carry && !numero[i]; // Actualizar el carry
    }

    return complemento;
}

bitset<46> multiplicar_mantissas(const bitset<23>& mantissa1, const bitset<23>& mantissa2) {
    unsigned long long producto_entero = mantissa1.to_ulong() * mantissa2.to_ulong();
    bitset<46> producto(producto_entero);

    return producto;
}

// Ajusta el exponente después de la multiplicación de mantissas
void ajustar_exponente(bitset<9>& exponente, bitset<46>& producto_mantissas) {
    if (producto_mantissas[45] == 1) {// Cuando el MSB del producto es 1, el resultado es mayor a 1
        producto_mantissas >>= 1;//desplaza el porducto
        exponente = sumarBitsets(exponente, bitset<9>("1"));//aumenta el exponente
    }
}
int main() {
    float valor1{0.0}, valor2{0.00};
    cout << "Ingrese valor float 1: "; cin >> valor1;
    cout << "Ingrese valor float 2: "; cin >> valor2;
    bitset<sizeof(float) * 8> repr_iee1 = numero_repr_iee(valor1); // Representación IEEE754 del número ingresado
    bitset<1> bit_signo1 = (repr_iee1[31] == 0 ? 0 : 1); // Separación bit de signo
    bitset<9> bits_exp1; // Ajustar a 9 bits
    for (int i = 30; i >= 23; i--) { // Separar la parte del exponente
        bits_exp1[i - 23] = repr_iee1[i];
    }
    bitset<23> bits_mantissa1;
    for (int i = 22; i >= 0; i--) { // Separar la parte del mantissa
        bits_mantissa1[i] = repr_iee1[i];
    }

    bitset<sizeof(float) * 8> repr_iee2 = numero_repr_iee(valor2); // Representación IEEE754 del número ingresado
    bitset<1> bit_signo2 = (repr_iee2[31] == 0 ? 0 : 1); // Separación bit de signo
    bitset<9> bits_exp2; // Ajustar a 9 bits
    for (int i = 30; i >= 23; i--) { // Separar la parte del exponente
        bits_exp2[i - 23] = repr_iee2[i];
    }
    bitset<23> bits_mantissa2;
    for (int i = 22; i >= 0; i--) { // Separar la parte del mantissa
        bits_mantissa2[i] = repr_iee2[i];
    }

    // Multiplicación de los mantissas
    bitset<46> producto_mantissas = multiplicar_mantissas(bits_mantissa1, bits_mantissa2);

    // Ajuste del exponente
    ajustar_exponente(bits_exp1, producto_mantissas);

    cout << "Producto de los mantissas: " << producto_mantissas << endl;
    cout << "Exponente ajustado tras la multiplicación de mantissas: " << bits_exp1 << endl;
    return 0;
}

# S-MIPS — CPU multiciclo de 32 bits

Proyecto de Arquitectura de Computadoras, Facultad de Matemática y Computación, Universidad de La Habana, curso 2026–2027.

Implementación de una CPU **S-MIPS multiciclo** sobre la placa proporcionada para **Logisim Evolution 5.0.0**. La memoria, el terminal y los controles de la placa pertenecen al diseño base del proyecto; el trabajo desarrollado se concentra en el procesador.

## Arquitectura

El circuito principal se encuentra en [`circuit/smips.circ`](circuit/smips.circ).

| Subcircuito | Función |
| `CPU` | Interconecta las unidades de procesamiento y control con la interfaz de la placa. |
| `Datapath` | Contiene PC, IR, registros temporales, multiplexores, extensores, banco de registros, ALU y rutas de memoria. |
| `Instruction_Decoder` | Identifica instrucciones a partir de `OPCODE` y, cuando corresponde, `FUNCT`. |
| `Control_Unit` | Máquina de estados finitos para la secuencia multiciclo y señales de control. |
| `Branch_Control` | Evalúa las condiciones de salto `BEQ` y `BNE` con la señal `ZERO`. |
| `ALU` | Operaciones ADD, SUB, AND, OR, SLT, SLL y SRL. |
| `Register_File` | Banco de 32 registros de 32 bits, con dos puertos de lectura y uno de escritura. |

### Versión inicial: VHDL

En esta versión, **`ALU` y `Register_File` están implementados en VHDL**; los demás subcircuitos están construidos con componentes de Logisim Evolution. Para simular la CPU completa con estos dos componentes es necesario configurar un simulador VHDL compatible (Questa) y su licencia.

Planeo desarrollar una version donde implemento estos componentes en logisim.

## Instrucciones decodificadas

- **Aritmética y lógica de registros:** `add`, `addu`, `sub`, `and`, `or`, `slt`, `sll`, `srl`.
- **Aritmética y lógica inmediata:** `addi`, `addiu`, `andi`, `ori`, `slti`.
- **Memoria:** `lw`, `sw`, `lb`, `lbu`, `sb`.
- **Control de flujo:** `beq`, `bne`, `j`, `jal`, `jr`.
- **Sistema:** `syscall`.

## Memoria y servicios de sistema

Se conserva la interfaz original de la placa, incluida la memoria de 16 KiB con habilitación por byte. El procesador utiliza direcciones de byte y el orden de bytes es *little-endian*.

Después de `RESET`, los valores requeridos son `PC = 0x0000`, `$gp = 0x1800`, `$sp = 0x3FFC` y `$zero = 0`.

Los servicios de sistema previstos son:

- **`$v0 = 10`:** activar `HALT` y detener la ejecución.
- **`$v0 = 11`:** imprimir el carácter de `$a0[6:0]` por la interfaz TTY (7 bits).

## Estructura del repositorio

```text
circuit/smips.circ       Circuito principal de Logisim
programs/               Ejemplos proporcionados en el repositorio base
tests/                  Pruebas adicionales propias en ensamblador S-MIPS
images/                 Imágenes de memoria generadas para los programas
tools/                  Ensamblador y herramientas de comprobación
docs/guide.pdf          Especificación oficial del proyecto
README.md               Documentación de esta implementación
```

## Preparación y ejecución

**Herramientas:** Logisim Evolution 5.0.0, Java 21 o superior, Python 3 y MARS 4.5. La versión con VHDL requiere además Questa configurado con licencia para ejecutar los componentes VHDL.

1. Ensamblar un programa de prueba desde la raíz del repositorio:

   ```bash
   python tools/assemble.py tests/test_arithmetic.asm
   ```

2. Abrir `circuit/smips.circ` en Logisim Evolution.
3. Acceder a la instancia de `Memory` desde la simulación de `Board` y cargar la imagen `.hex` generada con **Load Image...**. No cargar la imagen en una copia aislada de `Memory` desde el panel de diseño.
4. Volver a `Board`, activar `RESET` y avanzar el reloj.

La herramienta proporcionada por el proyecto permite ejecutar las pruebas y comparar la salida del TTY con MARS:

```bash
python tools/run_tests.py
```

La ejecución automática requiere que las rutas de Java, MARS y Logisim estén configuradas; en esta versión también es necesario contar con Questa y una licencia válida.

**Advertencia:** no ejecutar `python tools/build.py` sobre este circuito: esa herramienta regenera `circuit/smips.circ` y puede sobrescribir la implementación.

## Pruebas propias

Las pruebas añadidas en `tests/` intentan detectar fallos de ejecución y muestran `OK` o `FAIL` por TTY antes de terminar mediante `syscall 10`:

| Archivo | Objetivo 
| `test_arithmetic.asm` | Suma, resta, AND, OR y SLT. 
| `test_memory_bytes.asm` | `sw`, `lw`, `sb`, `lb` y `lbu` con byte de signo negativo. 
| `test_branches.asm` | `beq`, `bne`, `j` y control de flujo. 

La especificación de referencia está en [`docs/guide.pdf`](docs/guide.pdf) y en el [repositorio original del proyecto](https://github.com/UH-Matcom-AC/Proyecto-S-MIPS-2026-2027).

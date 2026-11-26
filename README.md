# S-MIPS | CPU multiciclo de 32 bits

**Proyecto individual de Arquitectura de Computadoras · MATCOM, Universidad de La Habana · Curso 2026–2027**

Implementación de un procesador **S-MIPS multiciclo** en **Logisim Evolution 5.0.0**, integrado con la placa `Board`, la memoria de 16 KiB y el terminal TTY del proyecto docente. La ALU y el banco de registros se implementan en **VHDL** y se simulan mediante **Questa FPGA Starter Edition**.

> **VERSIÓN DEFINITIVA — FUNCIONAL Y PROBADA.** La CPU S-MIPS está terminada y funciona en **Logisim Evolution 5.0.0 con Questa FPGA Starter Edition**. Se ejecutaron correctamente los programas de la batería de pruebas, incluidas las **ocho pruebas cortas** y la detección de instrucciones ilegales. En todos los casos ensayados, el terminal TTY produjo la salida esperada y la CPU activó `HALT` cuando correspondía. También se validaron paso a paso `ADDI`, `LUI`, `syscall 10` y `syscall 11`, con escrituras correctas en el banco de registros. El diseño descrito aquí es **la versión final que funciona**, no una propuesta ni una versión anterior.

## Arquitectura

```text
Board (placa base, sin cambios)
├── Memory (RAM 4096 x 32, escritura por bytes)
└── CPU
    ├── Instruction_Decoder (Logisim)
    ├── Control_Unit        (Logisim, FSM multiciclo)
    ├── Branch_Control      (Logisim)
    └── Datapath            (Logisim)
        ├── ALU             (VHDL)
        └── Register_File   (VHDL)
```

- **Una sola ALU**, compartida para `PC+4`, direcciones de memoria, ramas, sumas/restas y operaciones lógicas.
- Registros internos `PC`, `IR`, `A`, `B`, `ALUOut`, `MDR` y `PC4`, de 32 bits.
- Control de escritura en flanco ascendente; instrucciones ejecutadas en varios ciclos sin pipeline.
- Memoria unificada de instrucciones y datos: 4096 palabras de 32 bits (16 KiB), *little-endian*, con habilitación de bytes `MEM_BE[3:0]`.
- El `IR` conserva la instrucción durante sus estados de ejecución. `IorD` selecciona la dirección del PC o una dirección de dato.
- `Branch_Control` resuelve `beq/bne`; `PCSource` selecciona actualización secuencial, rama, salto inmediato o `jr`.

### Máquina de estados

| Código | Estado | Función principal |
|:---:|---|---|
| 0 | `FETCH` | Leer instrucción; calcular y guardar `PC+4` |
| 1 | `DECODE` | Leer registros y clasificar instrucción |
| 2 | `MEM_ADDR` | Calcular dirección efectiva |
| 3 | `MEM_READ` | Leer palabra de memoria |
| 4 | `MEM_WRITE` | Escribir palabra o byte |
| 5 | `MEM_WB` | Escribir resultado de lectura al registro |
| 6 | `EXEC` | Operación aritmética o lógica |
| 7 | `ALU_WB` | Escribir resultado de ALU o `LUI` |
| 8 | `BRANCH` | Evaluar `beq/bne` y actualizar PC si corresponde |
| 9 | `JUMP` | `j`, `jal` o `jr` |
| 10 | `SYSCALL` | Imprimir carácter o detener ejecución |

Los caminos comunes son `FETCH → DECODE → EXEC → ALU_WB → FETCH` para operaciones aritméticas, `FETCH → DECODE → MEM_ADDR → MEM_READ → MEM_WB → FETCH` para cargas, y `FETCH → DECODE → MEM_ADDR → MEM_WRITE → FETCH` para almacenes. Los saltos y `syscall` regresan a `FETCH` tras su estado específico salvo que se active `HALT`.

## Repertorio de instrucciones

La versión definitiva implementa las **25 instrucciones** de la orientación ([R8] y [R9]):

| Categoría | Instrucciones |
|---|---|
| Tipo R | `add`, `addu`, `sub`, `and`, `or`, `slt`, `sll`, `srl` |
| Inmediatas | `addi`, `addiu`, `slti`, `andi`, `ori`, `lui` |
| Memoria | `lw`, `sw`, `lb`, `lbu`, `sb` |
| Control | `beq`, `bne`, `j`, `jal`, `jr` |
| Sistema | `syscall` |

`lui` utiliza un inmediato **`IR[15:0]` extendido con ceros y desplazado 16 posiciones**, y el multiplexor de escritura selecciona `LUI_DATA` cuando `MemtoReg = 11`. `andi` y `ori` usan la extensión con ceros; el resto de inmediatos aritméticos y desplazamientos de rama utilizan extensión con signo.

`syscall 11` imprime `R[$a0][6:0]` mediante el TTY; `syscall 10` activa `HALT` hasta el siguiente RESET. Una codificación desconocida se detecta durante `DECODE` y activa la parada. La palabra `0x00000000` es `nop` válido. No se implementan los servicios 1, 4 o 5 de MARS.

### Codificación de la ALU VHDL

| `ALU_OP` | Operación |
|:---:|---|
| `000` | ADD |
| `001` | SUB |
| `010` | AND |
| `011` | OR |
| `100` | SLT con signo |
| `101` | SLL de B por A[4:0] |
| `110` | SRL lógico de B por A[4:0] |
| `111` | Reservado: resultado cero |

## Requisitos de software

- **Java 21+** y **Logisim Evolution 5.0.0**.
- **Questa Intel/Altera FPGA Starter Edition**, con licencia gratuita activada. En Windows, configurar `SALT_LICENSE_SERVER` con la ruta del archivo de licencia y la ruta de Questa en las preferencias de Logisim.
- **Python 3** y **MARS 4.5** para ensamblado y comparación de resultados.
- Para el proyecto oficial en Linux, `LOGISIM_JAR`, `MARS_JAR`, `QUESTA_BIN` y `SALT_LICENSE_SERVER` según la guía.

## Ejecución manual en Logisim

1. Abrir **`circuit/smips.circ`**; comprobar que `Simulación activada` y `Sim VHDL activada` estén marcadas, y que Questa llegue a `TCL_BINDER_RUNNING`.
2. Abrir **la instancia de `Memory` dentro de `Active Simulations → Board`**; clic derecho sobre RAM → **Cargar imagen** y escoger un `.hex` con formato `v2.0 raw` de Logisim.
3. Volver a `Board`, pulsar y soltar **Reset** (no usar `Ctrl+R` para limpiar el programa cargado).
4. Activar el reloj automático o usar `Tick ciclo completo`; observar TTY y LED `HALT`.
5. Antes de cambiar de programa, detener el reloj, cargar el siguiente `.hex` y volver a pulsar Reset.

Ejemplo de ensamblado con las herramientas originales:

```bash
python3 tools/assemble.py tests/01_aritmetica.asm
```

Comprobación oficial de todos los programas, **desde la raíz del repositorio**:

```bash
python3 tools/run_tests.py > salida-tests.txt 2>&1
```

**No crear manualmente `salida-tests.txt`:** debe ser la salida íntegra de esa ejecución sobre la versión final `circuit/smips.circ`. El resultado de las pruebas cortas no sustituye esa comparación automatizada contra MARS. **No ejecutar `tools/build.py` sobre el circuito definitivo** si la herramienta regenera el `.circ`.

## Pruebas de funcionamiento superadas en la CPU definitiva (Logisim + Questa)

| Prueba | Objetivo | TTY esperado | HALT | Confirmación |
|---|---|:---:|:---:|---|
| `01_aritmetica` | Sumas, restas, `addu`, `addiu` y negativos | `5` | 1 | **OK — funciona** |
| `02_lui_logica` | `lui`, `ori`, `andi`, desplazamiento | `B` | 1 | **OK — funciona** |
| `03_comparaciones` | `slt`, `slti`, `and`, `or`, `sll` | `C` | 1 | **OK — funciona** |
| `04_sw_lw` | `sw`/`lw` en la RAM | `D` | 1 | **OK — funciona** |
| `05_sb_lb_lbu` | Byte con bit 7, signo y extensión con ceros | `E` | 1 | **OK — funciona** |
| `06_beq_bne_j` | Saltos tomados/no tomados y hacia atrás | `3` | 1 | **OK — funciona** |
| `07_jal_jr` | Llamada y retorno | `7` | 1 | **OK — funciona** |
| `08_zero_nop` | Inmutabilidad de `$zero`, instrucción `nop` | `Z` | 1 | **OK — funciona** |
| `09_ilegal.hex` | Código de operación desconocido | *vacío* | 1 | **OK — funciona** |

**Resultado: 9/9 casos de esta batería superados en la CPU definitiva.** Las ocho pruebas funcionales y la prueba de instrucción ilegal finalizaron con las salidas y las condiciones de parada esperadas. Las salidas también fueron contrastadas mediante un verificador independiente de semántica S-MIPS.

La **comparación automatizada oficial con MARS** mediante `tools/run_tests.py` y la cobertura exhaustiva de cada fila de la tabla 3 de [R21] son requisitos específicos de entrega, distintos de estas pruebas manuales ya superadas. No se atribuyen resultados a esa ejecución automática mientras no se disponga de su registro real.

## Estructura de entrega

```text
S-MIPS/
├── circuit/
│   ├── smips.circ                 # CPU definitiva, probada con Questa
│   ├── alu.vhd
│   └── register_file.vhd
├── tests/                        # programas propios en ASM
│   ├── 01_aritmetica.asm
│   ├── ...
│   └── 08_zero_nop.asm
├── images/tests_cortos/          # HEX y caso ilegal para pruebas manuales
├── programs/                     # material original de la orientación
├── images/                       # imágenes originales de la orientación
├── tools/                        # herramientas originales
├── docs/guide.pdf                # orientación original
├── informe.pdf
├── salida-tests.txt              # generar solo con run_tests.py
├── open.sh
└── README.md
```

## Estado final

**CPU COMPLETA, FUNCIONAL Y PROBADA EN LOGISIM + QUESTA.** El diseño definitivo ejecuta correctamente los programas de prueba realizados, incluidos cálculos aritméticos, operaciones lógicas, acceso a memoria por palabras y bytes, saltos, procedimientos, `LUI`, terminal TTY y detención por `syscall` o instrucción ilegal.

**Documentación de entrega:** el registro `salida-tests.txt` deberá generarse con la ejecución real de `tools/run_tests.py` sobre `circuit/smips.circ`. Asimismo, los archivos VHDL externos deben corresponder al código incrustado en el circuito y el informe debe recoger la cobertura de la tabla 3 exigida por [R21]. Estas comprobaciones documentales no cambian el resultado satisfactorio de las pruebas manuales ya realizadas.

## Referencias

- [Orientación oficial del proyecto S-MIPS 2026–2027](https://github.com/UH-Matcom-AC/Proyecto-S-MIPS-2026-2027)
- [Repositorio de trabajo](https://github.com/cala49/S-MIPS)
- Especificación local: `docs/guide.pdf`, especialmente requisitos [R1]–[R23].

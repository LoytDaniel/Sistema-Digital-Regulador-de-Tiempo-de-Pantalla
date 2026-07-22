# Sistema Digital Regulador de Tiempo en Pantalla

![Verilog](https://img.shields.io/badge/HDL-Verilog-blue?logo=v&logoColor=white)
![FPGA](https://img.shields.io/badge/Platform-Cyclone%20IV-orange)
![Quartus](https://img.shields.io/badge/Toolchain-Quartus-purple)
![Status](https://img.shields.io/badge/Status-Completado-brightgreen)
![License](https://img.shields.io/badge/License-Academic%20Project-lightgrey)

Sistema digital basado en FPGA para el **control del tiempo de uso de un televisor**, orientado a la construcción de hábitos saludables de consumo de pantallas en niños. El dispositivo interrumpe el flujo de corriente hacia el televisor una vez se agota el tiempo configurado o fuera de la franja horaria permitida, gestionado íntegramente mediante máquinas de estados finitos (FSM) descritas en Verilog.

> Proyecto desarrollado para el curso de Sistemas Digitales — Departamento de Ingeniería Mecánica y Mecatrónica, Universidad Nacional de Colombia.

**Autores:** Daniela Sabogal Suarez · Daniel Felipe Loy Arias · Juan David Garcia Barreto

---

## Tabla de contenido

- [Descripción general](#descripción-general)
- [Arquitectura del sistema](#arquitectura-del-sistema)
- [Interfaz de usuario](#interfaz-de-usuario)
- [Módulos implementados](#módulos-implementados)
- [Máquinas de estado](#máquinas-de-estado)
- [Hardware y circuito](#hardware-y-circuito)
- [Modelado 3D / Carcasa](#modelado-3d--carcasa)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Pruebas y validación](#pruebas-y-validación)
- [Resultados](#resultados)
- [Uso de IA](#uso-de-ia)
- [Referencias](#referencias)

---

## Descripción general

El sistema controla el tiempo de uso diario de un televisor mediante una FPGA que integra sensores de entrada (teclado matricial, módulo RTC, pulsadores) y actuadores de salida (relé, pantalla LCD gráfica). El cuidador configura un tiempo máximo de uso y una franja horaria permitida; al agotarse el tiempo o salir del horario configurado, el sistema corta la alimentación del televisor automáticamente.

| Característica | Detalle |
|---|---|
| Plataforma | FPGA Cyclone IV |
| Lenguaje | Verilog (HDL) |
| Entradas | Teclado matricial 4×4, módulo RTC DS1302, pulsadores PLAY/PAUSE |
| Salidas | Relé (corte de alimentación), pantalla LCD gráfica 128×64 |
| Pantallas del sistema | Kids Mode, Password, Main Menu, Adult Mode, Settings |

---

## Arquitectura del sistema

El diagrama de bloques resume la interacción entre sensores, la unidad de control (FPGA) y los actuadores del sistema.

<p align="center">
  <img src="docs/images/diagrama_bloques.png" alt="Diagrama de bloques del sistema" width="600">
</p>

---

## Interfaz de usuario

La navegación se realiza mediante el teclado matricial entre cinco pantallas: **Kids Mode** (pantalla predeterminada, muestra el tiempo restante), **Password** (acceso protegido), **Main Menu**, **Adult Mode** (hora real sin restricciones) y **Settings** (configuración de tiempo máximo y franja horaria en formato HH:MM).

<p align="center">
  <img src="docs/images/interfaz_navegacion.png" alt="Diagrama de navegación entre pantallas" width="650">
</p>

| Pantalla | Función | Captura |
|---|---|---|
| Kids Mode | Tiempo restante + control PLAY/PAUSE | `docs/images/foto_kids_mode.jpg` |
| Password | Ingreso de clave (Accept / Delete / Exit) | `docs/images/foto_password.jpg` |
| Adult Mode | Hora real, restricciones deshabilitadas | `docs/images/foto_adult_mode.jpg` |
| Settings | Configuración de tiempo e inicio/fin | `docs/images/foto_settings.jpg` |

---

## Módulos implementados

| Módulo | Descripción |
|---|---|
| **RTC (DS1302)** | Interfaz serie síncrona de 3 hilos (CE, SCLK, IO) para lectura/escritura del reloj en tiempo real. Actualización automática cada segundo. |
| **LCD 128×64** | Controla dos chips (CS1/CS2 de 64×64 px c/u), inicializa el display y escribe los mapas de bits de cada pantalla, actualizando hora, tiempo restante y cursor. |
| **Keyboard** | Escaneo de matriz 4×4 con divisor de reloj a 1 ms, FSM de escaneo/debounce (20 ciclos) y decodificación a BCD + teclas especiales. |
| **Password** | Captura hasta 4 dígitos, sincronización de señales externas (metaestabilidad) y comparación contra `DEFAULT_PASSWORD`. Combinacional, sin FSM. |
| **Screen Changes / Menú** | FSM principal de navegación entre las 5 pantallas, controlada por `exit`, `correct_password` y `sel`. |
| **Kids Mode (Timer + Franja Horaria)** | Cuenta regresiva del tiempo disponible, soporte de franjas nocturnas (cruce de medianoche), reinicio diario automático a las 00:00. |
| **Relé** | Módulo combinacional: corta la alimentación si `time_finish` en Kids Mode, o durante la pantalla Password. |
| **Settings** | FSM de 2 estados (selección / edición) para configurar Tiempo, Inicio y Final en formato HH:MM, con saturación de valores a rango 24h válido. |

---

## Máquinas de estado

<details>
<summary><b>Controlador RTC y configuración de hora</b></summary>
<p align="center">
  <img src="docs/images/fsm_rtc.png" alt="FSM del RTC" width="600">
</p>
</details>

<details>
<summary><b>Controlador LCD 128×64</b></summary>
<p align="center">
  <img src="docs/images/fsm_lcd.png" alt="FSM del LCD" width="600">
</p>
</details>

<details>
<summary><b>Teclado matricial</b></summary>
<p align="center">
  <img src="docs/images/fsm_teclado.png" alt="FSM del teclado" width="500">
</p>
</details>

<details>
<summary><b>Cambio de pantallas / menú principal</b></summary>
<p align="center">
  <img src="docs/images/fsm_menu.png" alt="FSM de cambio de pantallas" width="600">
</p>
</details>

<details>
<summary><b>Botones PLAY/PAUSE</b></summary>
<p align="center">
  <img src="docs/images/fsm_botones.png" alt="FSM de botones" width="500">
</p>
</details>

<details>
<summary><b>Configuración (Settings)</b></summary>
<p align="center">
  <img src="docs/images/fsm_settings.png" alt="FSM de configuración" width="500">
</p>
</details>

---

## Hardware y circuito

El sistema utiliza una FPGA Cyclone IV como unidad de control central, conectada a:

- **Teclado matricial 4×4** y **switches PLAY/PAUSE** — entrada de usuario
- **Módulo RTC DS1302** — actualiza la hora real de forma autónoma
- **Módulo de relé (optoacoplado)** — corta la alimentación del televisor (cargas de mayor voltaje)
- **Pantalla LCD gráfica 128×64** — interfaz visual

<p align="center">
  <img src="docs/images/circuito_electrico.png" alt="Circuito eléctrico del dispositivo" width="650">
</p>

---

## Modelado 3D / Carcasa

Carcasa diseñada para alojar la FPGA, el módulo de relé, el RTC, el teclado matricial y la pantalla LCD de forma compacta.

<p align="center">
  <img src="docs/images/modelado_3d_1.png" alt="Render del modelado 3D - vista 1" width="45%">
  <img src="docs/images/modelado_3d_2.png" alt="Render del modelado 3D - vista 2" width="45%">
</p>

<p align="center">
  <img src="docs/images/carcasa_fisica.jpg" alt="Carcasa física impresa" width="500">
</p>

---

## Estructura del repositorio

```
Sistema-Digital-Regulador-de-Tiempo-de-Pantalla/
├── FINAL/                    # Integración final del sistema
├── Keyboard_fsm/              # Módulo de teclado matricial 4x4
├── Kids_screen/                # Timer + franja horaria + Kids Mode
├── LCD_128X64/                 # Controlador de pantalla gráfica
├── Menu_screen/                 # Navegación entre pantallas (FSM principal)
├── Password_screen/             # Módulo de validación de contraseña
├── RTC_DS1302/                   # Interfaz con el reloj en tiempo real
├── Screens_Change/                # Lógica de cambio de ventanas
├── Settings_screen/                # Configuración de tiempo y franja horaria
├── relee_controller.v                # Módulo combinacional del relé
├── LCD12864_BitmapFont.xlsx           # Fuente de caracteres bitmap para el LCD
└── README.md
```

## Pruebas y validación

El desarrollo se realizó de forma **incremental**: cada módulo se validó de manera independiente antes de la integración completa en protoboard y, posteriormente, en PCB.

- ✅ **Teclado matricial** — respuesta correcta a las 16 teclas, debounce sin lecturas repetidas.
- ✅ **RTC DS1302** — hora coincidente con la referencia, actualización cada segundo, persistencia tras cortes de energía (batería de respaldo).
- ✅ **LCD 128×64** — inicialización correcta de ambos controladores (CS1/CS2) y escritura precisa de las 5 interfaces.
- ✅ **Control parental** — acceso solo con contraseña correcta; mensaje `INCORRECT` ante clave inválida sin bloquear el sistema.
- ✅ **Settings** — desplazamiento automático de cursor, saturación de valores fuera de rango (formato 24h).
- ✅ **Timer y relé** — inicio/pausa sin pérdida de tiempo acumulado, franjas nocturnas (cruce de medianoche), corte inmediato al agotar el tiempo, reinicio diario automático a las 00:00.

---

## Resultados

El sistema cumple satisfactoriamente los objetivos planteados, logrando un dispositivo **funcional, modular y de fácil mantenimiento**, gracias al uso de máquinas de estados finitos independientes por módulo y su integración bajo una FSM principal de navegación.

---

## Uso de IA

Como herramienta de apoyo se utilizó **Claude**, principalmente para la verificación de sintaxis de los módulos en Verilog, el análisis de errores de compilación en Quartus, la identificación de inconsistencias en la descripción de hardware, ayuda en la estetica del repositorio de GitHub y la generación de los diagramas de las máquinas de estado presentados en este documento.

---

## Referencias

1. E. S. Sánchez, *Infancia y medios audiovisuales: análisis sobre la oferta de contenidos dirigidos a niños, niñas y adolescentes en televisión abierta*, Informe final de consultoría, CRC, Bogotá, 2024.
2. American Academy of Child and Adolescent Psychiatry, "Screen Time and Children," *Facts for Families* No. 54, jun. 2025.
3. MinhTran, [DS1302_Interface_DE10](https://github.com/MinhTran0911/DS1302_Interface_DE10) — GitHub.
4. D. Harris y S. Harris, *Digital Design and Computer Architecture*, Elsevier.
5. Dallas Semiconductor, [DS1302 Trickle-Charge Timekeeping Chip — Datasheet](https://www.analog.com/media/en/technical-documentation/data-sheets/ds1302.pdf).
6. HandsOn Technology, [128×64 Dot Graphic LCD Module — User Guide](https://www.handsontec.com).

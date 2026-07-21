# Sistema-Digital-Regulador-de-Tiempo-de-Pantalla

En el presente documento se presentan el desarrollo de un dispositivo electrónico para el control del tiempo de uso de la televisión. El sistema permite limitar el acceso al televisor mediante la interrupción del flujo de corriente una vez se alcance el tiempo de uso previamente establecido, contribuyendo a la construcción de hábitos de uso saludables de pantallas.

Este proyecto surge como respuesta a la preocupación por las posibles consecuencias asociadas al uso prolongado y no supervisado de dispositivos electrónicos durante la infancia, entre las que se encuentran alteraciones del sueño, aumento del riesgo de sobrepeso, dificultades en el aprendizaje y problemas en el desarrollo de habilidades sociales. 

## Funcionamiento General del Sistema

El proyecto implementa una pantalla LCD de 128X64 píxeles, encargada de mostrar las diferentes interfaces del sistema. La pantalla predeterminada corresponde al modo Kids Mode, en la cual se presenta el tiempo restante de uso del dispositivo y un indicador del estado del temporizador. En esta interfaz también se emplean dos pulsadores externos, PLAY y PAUSE, que permiten al niño iniciar o detener temporalmente la cuenta regresiva del tiempo disponible.

La navegación entre las distintas pantallas se realiza mediante un teclado. Desde la pantalla Kids Mode es posible acceder a la pantalla Password, donde se solicita el ingreso de una contraseña predeterminada para restringir el acceso a la configuración del sistema. Esta pantalla incorpora las funciones Accept, para validar la contraseña ingresada; Delete, para eliminar los caracteres digitados; y Exit, para regresar a la pantalla principal sin realizar modificaciones. En caso de que la contraseña sea incorrecta, el sistema muestra el mensaje "INCORRECT", permitiendo al usuario ingresar nuevamente la clave.

Una vez validada correctamente la contraseña, se habilita el acceso al Main Menu, desde el cual el cuidador puede seleccionar entre las opciones Adult Mode y Settings. La primera permite deshabilitar temporalmente las restricciones del sistema, mostrando la hora actual obtenida del RTC. La segunda opción permite configurar los parámetros de funcionamiento, incluyendo el tiempo máximo diario de uso, la hora de inicio y la hora de finalización del periodo permitido. Durante la edición de estos parámetros, el cursor se desplaza automáticamente entre los campos del formato HH:MM conforme se ingresan los valores numéricos, mientras que la opción Accept guarda la configuración y Exit retorna al menú principal sin efectuar cambios.

## Modulos Implementados
- Módulo RTC: Gestiona la comunicación con el reloj DS1302 para leer y actualizar la hora en tiempo real, utilizada por el sistema para la visualización y el control de las franjas horarias.

- Módulo LCD 128×64: Inicializa la pantalla y administra la escritura de la memoria gráfica, mostrando las diferentes interfaces del sistema y actualizando dinámicamente la información en pantalla.

- Módulo Keyboard: Escanea el teclado matricial 4×4, elimina el rebote de las teclas (debounce), decodifica las pulsaciones y genera las señales correspondientes para números y teclas especiales.

- Módulo Password: Captura la contraseña ingresada por el usuario, la compara con la contraseña almacenada y genera las señales de acceso correcto o incorrecto.

- Módulo Screen Changes / Menú: Controla la navegación entre las diferentes pantallas del sistema mediante una máquina de estados, habilitando únicamente la interfaz correspondiente al estado actual.

- Módulo Kids Mode: Administra el temporizador de uso, verifica el cumplimiento de la franja horaria permitida y controla la activación del relé para habilitar o bloquear el televisor.

- Módulo Relé: Activa o desactiva la alimentación del televisor de acuerdo con las decisiones tomadas por el módulo de control del tiempo de uso.

- Módulo Settings: Permite configurar el tiempo máximo diario y las horas de inicio y fin del periodo permitido, validando y almacenando los parámetros ingresados por el usuario.

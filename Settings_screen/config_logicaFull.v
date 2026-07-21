//=====================================================================
// Modulo: config_logica
// Descripcion: Logica de control (SIN manejo de LCD) para la pantalla
//              de CONFIGURACION del sistema de control parental.
//
//              Permite al usuario elegir una de 3 filas:
//                  1 -> TIEMPO   (temporizador)
//                  2 -> INICIO   (franja horaria - inicio)
//                  3 -> FINAL    (franja horaria - final)
//
//              y luego editar sus 4 digitos, en este orden fijo:
//                  decena hora -> unidad hora -> decena minuto -> unidad minuto
//
//              Al completar el 4to digito, regresa automaticamente a
//              esperar una nueva seleccion de fila (1, 2 o 3).
//
// Codificacion de posicion_fila:
//      00 = Tiempo   01 = Inicio   10 = Final
// Codificacion de posicion_columna:
//      00 = decena hora   01 = unidad hora
//      10 = decena minuto 11 = unidad minuto
//
// Notas / supuestos de diseno:
//   - key_out solo se interpreta como digito valido si esta en el
//     rango 0-9. Cualquier otro valor (letras/simbolos del teclado,
//     que llegan por defecto como 4'b1111) se ignora como digito.
//   - Aceptar, presionado durante la edicion de una fila, finaliza
//     esa edicion de forma anticipada (los digitos que no se
//     alcanzaron a ingresar conservan su valor anterior) y regresa
//     a la seleccion de opcion 1/2/3.
//   - "exit" es un pulso de 1 ciclo de reloj cuando se detecta Salir.
//   - Los valores configurados (tiempo/inicio/final) se guardan en
//     registros y se conservan aunque el usuario salga del modulo o
//     "setting" se desactive (no se borran, solo se dejan de leer
//     nuevas teclas).
//=====================================================================

module config_logicaFull (
    input  wire clk,
    input  wire rst,
    input  wire Aceptar,
    input  wire Salir,
    input  wire setting,       // enable dado por la FSM superior
    input  wire [3:0] key_out,       // digito BCD del teclado (0-9), 4'b1111 = no valido
    input  wire push_button,   // pulso "hay una tecla nueva" del teclado

    output reg  exit,          // bandera de 1 ciclo hacia la FSM superior
    output reg  [7:0] tiempo_hr,     // [7:4]=decena [3:0]=unidad
    output reg  [7:0] tiempo_min,    // [7:4]=decena [3:0]=unidad
    output reg  [7:0] inicio_hr,     // [7:4]=decena [3:0]=unidad
    output reg  [7:0] inicio_min,    // [7:4]=decena [3:0]=unidad
    output reg  [7:0] final_hr,      // [7:4]=decena [3:0]=unidad
    output reg  [7:0] final_min,     // [7:4]=decena [3:0]=unidad
    output reg  [1:0] posicion_fila,
    output reg  [1:0] posicion_columna
);

    //-----------------------------------------------------------------
    // Valores por defecto (formato BCD, un nibble hex = un digito)
    //-----------------------------------------------------------------
    localparam [7:0] TIEMPO_HR_DEF  = 8'h01; // 2 horas
    localparam [7:0] TIEMPO_MIN_DEF = 8'h00; // 0 minutos
    localparam [7:0] INICIO_HR_DEF  = 8'h09; // 09
    localparam [7:0] INICIO_MIN_DEF = 8'h00; // 00
    localparam [7:0] FINAL_HR_DEF   = 8'h23; // 19
    localparam [7:0] FINAL_MIN_DEF  = 8'h00; // 00

    //-----------------------------------------------------------------
    // Limites para saturacion (formato 24h, minutos 0-59)
    //-----------------------------------------------------------------
    localparam [3:0] MAX_DEC_HORA      = 4'd2; // decena de hora max = 2 (20-23)
    localparam [3:0] MAX_DEC_MIN       = 4'd5; // decena de minuto max = 5 (50-59)
    localparam [3:0] MAX_UNI_HORA_TOPE = 4'd3; // si decena hora = 2, unidad max = 3

    //-----------------------------------------------------------------
    // Estados / posiciones
    //-----------------------------------------------------------------
    localparam ST_SELECT = 1'b0; // esperando seleccion de opcion 1/2/3
    localparam ST_EDIT   = 1'b1; // editando digitos de la fila elegida

    localparam FILA_TIEMPO = 2'b00;
    localparam FILA_INICIO = 2'b01;
    localparam FILA_FINAL  = 2'b10;
    localparam WAITING     = 2'b11;

    localparam COL_DEC_HR  = 2'b00;
    localparam COL_UNI_HR  = 2'b01;
    localparam COL_DEC_MIN = 2'b10;
    localparam COL_UNI_MIN = 2'b11;

    reg estado;

    //-----------------------------------------------------------------
    // Deteccion de flanco de subida (evita lectura multiple con la
    // tecla sostenida)
    //-----------------------------------------------------------------
    reg push_button_d, Aceptar_d, Salir_d;

    always @(posedge clk) begin
        if (rst) begin
            push_button_d <= 1'b0;
            Aceptar_d     <= 1'b0;
            Salir_d       <= 1'b0;
        end else begin
            push_button_d <= push_button;
            Aceptar_d     <= Aceptar;
            Salir_d       <= Salir;
        end
    end

    wire push_button_re = push_button & ~push_button_d;
    wire Aceptar_re     = Aceptar     & ~Aceptar_d;
    wire Salir_re       = Salir       & ~Salir_d;

    //-----------------------------------------------------------------
    // Validacion de tecla como digito BCD (0-9)
    //-----------------------------------------------------------------
    wire key_es_digito = (key_out <= 4'd9);

    //-----------------------------------------------------------------
    // Saturacion combinacional de decenas
    //-----------------------------------------------------------------
    wire [3:0] dec_hr_sat  = (key_out > MAX_DEC_HORA) ? MAX_DEC_HORA : key_out;
    wire [3:0] dec_min_sat = (key_out > MAX_DEC_MIN)  ? MAX_DEC_MIN  : key_out;

    initial begin
            tiempo_hr  <= TIEMPO_HR_DEF;
            tiempo_min <= TIEMPO_MIN_DEF;
            inicio_hr  <= INICIO_HR_DEF;
            inicio_min <= INICIO_MIN_DEF;
            final_hr   <= FINAL_HR_DEF;
            final_min  <= FINAL_MIN_DEF;
    end

    //-----------------------------------------------------------------
    // FSM principal
    //-----------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            estado           <= ST_SELECT;
            posicion_fila    <= WAITING;
            posicion_columna <= COL_DEC_HR;
            exit             <= 1'b0;

            tiempo_hr  <= TIEMPO_HR_DEF;
            tiempo_min <= TIEMPO_MIN_DEF;
            inicio_hr  <= INICIO_HR_DEF;
            inicio_min <= INICIO_MIN_DEF;
            final_hr   <= FINAL_HR_DEF;
            final_min  <= FINAL_MIN_DEF;

        end else if (setting) begin

            exit <= 1'b0; // por defecto en bajo, se pulsa solo 1 ciclo

            if (Salir_re) begin
                // El usuario sale del modulo de configuracion.
                // Los valores ya guardados (tiempo/inicio/final) NO se tocan.
                exit             <= 1'b1;
                estado           <= ST_SELECT;
                posicion_columna <= COL_DEC_HR;

            end else begin
                case (estado)

                    //---------------------------------------------
                    // Esperando que el usuario elija 1 (Tiempo),
                    // 2 (Inicio) o 3 (Final)
                    //---------------------------------------------
                    ST_SELECT: begin
                        if (push_button_re) begin
                            case (key_out)
                                4'd1: begin
                                    posicion_fila    <= FILA_TIEMPO;
                                    posicion_columna <= COL_DEC_HR;
                                    estado           <= ST_EDIT;
                                end
                                4'd2: begin
                                    posicion_fila    <= FILA_INICIO;
                                    posicion_columna <= COL_DEC_HR;
                                    estado           <= ST_EDIT;
                                end
                                4'd3: begin
                                    posicion_fila    <= FILA_FINAL;
                                    posicion_columna <= COL_DEC_HR;
                                    estado           <= ST_EDIT;
                                end
                                default: begin
                                    // tecla no valida para esta seleccion (ej. 4-9, letras): se ignora
                                end
                            endcase
                        end
                        else begin
                            posicion_fila    <= WAITING;
                        end
                    end

                    //---------------------------------------------
                    // Editando los 4 digitos de la fila seleccionada
                    //---------------------------------------------
                    ST_EDIT: begin
                        if (Aceptar_re) begin
                            // Se acepta la edicion (completa o parcial) y
                            // se regresa a elegir opcion. Los digitos no
                            // alcanzados a ingresar conservan su valor previo.
                            estado           <= ST_SELECT;
                            posicion_columna <= COL_DEC_HR;

                        end else if (push_button_re && key_es_digito) begin
                            case (posicion_columna)

                                //----- Decena de hora -----
                                COL_DEC_HR: begin
                                    case (posicion_fila)
                                        FILA_TIEMPO: tiempo_hr[7:4] <= dec_hr_sat;
                                        FILA_INICIO: inicio_hr[7:4] <= dec_hr_sat;
                                        FILA_FINAL:  final_hr[7:4]  <= dec_hr_sat;
                                    endcase
                                    posicion_columna <= COL_UNI_HR;
                                end

                                //----- Unidad de hora -----
                                // Si la decena guardada es 2, la unidad se
                                // topa en 3 (23 max). Si no, la unidad es libre (0-9).
                                COL_UNI_HR: begin
                                    case (posicion_fila)
                                        FILA_TIEMPO: begin
                                            if (tiempo_hr[7:4] == MAX_DEC_HORA && key_out > MAX_UNI_HORA_TOPE)
                                                tiempo_hr[3:0] <= MAX_UNI_HORA_TOPE;
                                            else
                                                tiempo_hr[3:0] <= key_out;
                                        end
                                        FILA_INICIO: begin
                                            if (inicio_hr[7:4] == MAX_DEC_HORA && key_out > MAX_UNI_HORA_TOPE)
                                                inicio_hr[3:0] <= MAX_UNI_HORA_TOPE;
                                            else
                                                inicio_hr[3:0] <= key_out;
                                        end
                                        FILA_FINAL: begin
                                            if (final_hr[7:4] == MAX_DEC_HORA && key_out > MAX_UNI_HORA_TOPE)
                                                final_hr[3:0] <= MAX_UNI_HORA_TOPE;
                                            else
                                                final_hr[3:0] <= key_out;
                                        end
                                    endcase
                                    posicion_columna <= COL_DEC_MIN;
                                end

                                //----- Decena de minuto -----
                                COL_DEC_MIN: begin
                                    case (posicion_fila)
                                        FILA_TIEMPO: tiempo_min[7:4] <= dec_min_sat;
                                        FILA_INICIO: inicio_min[7:4] <= dec_min_sat;
                                        FILA_FINAL:  final_min[7:4]  <= dec_min_sat;
                                    endcase
                                    posicion_columna <= COL_UNI_MIN;
                                end

                                //----- Unidad de minuto (no requiere saturacion) -----
                                COL_UNI_MIN: begin
                                    case (posicion_fila)
                                        FILA_TIEMPO: tiempo_min[3:0] <= key_out;
                                        FILA_INICIO: inicio_min[3:0] <= key_out;
                                        FILA_FINAL:  final_min[3:0]  <= key_out;
                                    endcase
                                    // Fila completa -> vuelve a esperar seleccion de opcion
                                    estado           <= ST_SELECT;
                                    posicion_columna <= COL_DEC_HR;
                                end
                            endcase
                        end
                    end
                endcase
            end
        end
        // Si setting = 0: no se toca ningun registro. Se conserva tanto la
        // posicion de navegacion (estado/fila/columna) como los valores
        // ya configurados de tiempo/inicio/final.
    end

endmodule

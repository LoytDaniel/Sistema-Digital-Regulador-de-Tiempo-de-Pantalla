module Final_Top (
    input clk, reset, wr_btn, set_btn, reset_rtc,
    input [5:0] ext_input,
    input [3:0] col,
    input start, pause,

    inout IO,

    output CE, SCLK,
    output di, // Data/Instruction (0=cmd, 1=dato)
    output rw, // Read/Write (siempre 0=write)
    output enable, // Pulso de habilitación (= clk_16ms)
    output cs1, // Chip Select lado izquierdo
    output cs2, // Chip Select lado derecho
    output [7:0] data,// Bus de datos 8 bits
    output [3:0] row,
    output off, temp,dd
);

//lógica invertida
wire nreset, noff;
assign nreset=~reset;
assign nstart=start;
assign npause=pause;
assign temp=~pause;

//Variables internas
wire incorrect_password, correct_password, kids, password, menu, adult, setting, timer_enable;
wire [1:0] options, posicion_fila, posicion_columna;
wire [3:0] key_out;
wire [7:0] hr_out, min_out, sec_out;
wire [2:0] puntero_digitos;
wire [7:0] left_time_BCD [0:1];
wire push_button, Aceptar, Borrar, Salir, clk_teclado;
wire temp_enable, time_finish;
wire [7:0] tiempo_hr, tiempo_min, inicio_hr, inicio_min, final_hr, final_min;

reg Salir_d, exit_sync1, exit_sync2;

always @(posedge clk_teclado or posedge nreset) begin
        if (nreset) begin
            exit_sync1 <= 1'b0;
            exit_sync2 <= 1'b0;
        end else begin
            exit_sync1 <= Salir;       // 1ra etapa: puede quedar metaestable, y no pasa nada
            exit_sync2 <= exit_sync1; // 2da etapa: ya estable, segura de usar
        end
end

always @(posedge clk_teclado) begin
        if (nreset) begin
            Salir_d <= 1'b0;
        end else begin
            Salir_d <= exit_sync2;
        end
end

wire Salir_re = exit_sync2 & ~Salir_d;

// FSM cambio de Pantalla
fsm_screen FS( 
    .clk(clk_teclado),
    .reset(nreset),
    .exit(Salir_re),
    .correct_password(correct_password),
    .sel(options),

    .kids(kids),
    .password(password),
    .menu(menu),
    .adult(adult),
    .setting(setting)
);

//Selección menu
select_menu sel(
    .menu(menu),
    .key_value(key_out),
    .options(options)
);

//RTC 
DS1302_Top_final DS1302 (
    .clk(clk), 
    .rstn(reset_rtc), 
    .wr_btn(wr_btn), 
    .set_btn(set_btn), 
    .ext_input(ext_input), 
    .CE(CE), 
    .SCLK(SCLK), 
    .IO(IO),
    .hr_out(hr_out),
    .min_out(min_out),
    .sec_out(sec_out)
);

//LCD
LCD12864_controller inst(
    .clk(clk),
    .reset(reset),
    .di(di), // Data/Instruction (0=cmd, 1=dato)
    .rw(rw), // Read/Write (siempre 0=write)
    .enable(enable), // Pulso de habilitación (= clk_16ms)
    .cs1(cs1), // Chip Select lado izquierdo
    .cs2(cs2), // Chip Select lado derecho
    .data(data),// Bus de datos 8 bits
    .kids(kids),
    .password(password), 
    .menu(menu), 
    .adult(adult), 
    .setting(setting),
    .timer_enable(timer_enable),
    .left_time_H(left_time_BCD[1]), 
    .left_time_M(left_time_BCD[0]),
    .current_hr(hr_out), 
    .current_min(min_out),
    .num_ingresados(puntero_digitos),
    .pass_incorrecta(incorrect_password),
    .tiempo_hr(tiempo_hr), 
    .tiempo_min(tiempo_min),
    .inicio_hr(inicio_hr), 
    .inicio_min(inicio_min),
    .final_hr(final_hr), 
    .final_min(final_min),
    .posicion_fila(posicion_fila), // 0: fila 1 (tiempo) 1: fila 2 (inicio) 2: fila 3 (final) 
    .posicion_columna(posicion_columna) // 0: columna 1 (decena hora) 1: columna 2 (unidades hora) 2: columna 3 (decena minuto) 3: columna 4 (unidades minuto)
);

config_logicaFull confFull (
    .clk(clk_teclado),
    .rst(nreset),
    .Aceptar(Aceptar),
    .Salir(Salir),
    .setting(setting),
    .key_out(key_out),
    .push_button(push_button),
    .tiempo_hr(tiempo_hr),
    .tiempo_min(tiempo_min),
    .inicio_hr(inicio_hr),
    .inicio_min(inicio_min),
    .final_hr(final_hr),
    .final_min(final_min),
    .posicion_fila(posicion_fila),
    .posicion_columna(posicion_columna)
);

// Teclado matricial
Keyboard_top keyboard (
    .clk(clk),
    .reset(reset),
    .col(col),
    .row(row),
    .key_out(key_out), 
    .push_button(push_button),
    .Aceptar(Aceptar),
    .Borrar(Borrar),
    .Salir(Salir),
    .clk1(clk_teclado)
);

//Contraseña
password_menu pass (
    .clk(clk_teclado),
    .rst(nreset),
    .push_button(push_button),
    .key_out(key_out),
    .Aceptar(Aceptar),
    .Borrar(Borrar),
    .password(password),
    .correct_password(correct_password),
    .incorrect_password(incorrect_password),
    .puntero_digitos(puntero_digitos),
);

//Timer 
Timer pt(
    .clk(clk),
    .reset(nreset),
    .start(nstart),
    .pause(npause),
    .kids(kids),
    .temp_enable(temp_enable),
    .current_time_H(hr_out),
    .current_time_M(min_out),
    .current_time_S(sec_out),
    .limit_time_H(tiempo_hr),
    .limit_time_M(tiempo_min), 
    .left_time_BCD_H(left_time_BCD[1]),
    .left_time_BCD_M(left_time_BCD[0]),
    .off_enable(time_finish),
    .timer_enable(timer_enable)
);

//Verificación cumplimiento franja horaria
franja_horaria fh(
    .reset(nreset),
    .inicio_hr(inicio_hr), 
    .inicio_min(inicio_min),
    .final_hr(final_hr), 
    .final_min(final_min),
    .current_time_H(hr_out), 
    .current_time_M(min_out),
    .temp_enable(temp_enable)
);

relee_controller rl(
    .kids(kids), 
    .password(password),
    .time_finish(time_finish),
    .off_enable(noff)
);

assign off = noff;

endmodule
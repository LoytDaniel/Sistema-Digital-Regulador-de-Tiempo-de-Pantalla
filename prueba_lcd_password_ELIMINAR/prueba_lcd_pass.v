module prueba_lcd_pass (
    input clk, reset,
    input [3:0] col,
    input password, //Enable de la FSM para este modulo
    output [3:0] row,
    output di, // Data/Instruction (0=cmd, 1=dato)
    output rw, // Read/Write (siempre 0=write)
    output enable, // Pulso de habilitación (= clk_16ms)
    output cs1, // Chip Select lado izquierdo
    output cs2, // Chip Select lado derecho
    output [7:0] data,// Bus de datos 8 bits
    //Variables para el cambio de pantalla
	 output correct_password,
	 output [3:0] key,key2,
    output [2:0] puntero_digitos //Indicador para la pantalla LED
);

wire nreset, ncorrect_password;
wire [3:0] key_out, key_in;
wire push_button, Aceptar, Borrar, Salir, is_digit, incorrect_password, clk_teclado;
wire [2:0] npuntero_digitos;
assign nreset = ~reset;
//assign key=~key_out;


Keyboard_top keyboard (
    .clk(clk),
    .reset(reset),
    .col(col),
    .row(row),
    .key_out(key_out), 
    //.key_in(key_in),
    .push_button(push_button),
    .Aceptar(Aceptar),
    .Borrar(Borrar),
    .Salir(Salir),
    .clk1(clk_teclado)
);

password_menu pass (
    .clk(clk_teclado),
    .rst(nreset),
    .push_button(push_button),
    .key_out(key_out),
    .Aceptar(Aceptar),
    .Borrar(Borrar),
    .password(password),
    .correct_password(ncorrect_password),
    .incorrect_password(incorrect_password),
    .puntero_digitos(npuntero_digitos),
	 .d1(key), .d2(key2)
);

LCD12864_controller_p2 lcd (
    .clk(clk),
    .reset(reset),
    .di(di),
    .rw(rw),
    .enable(enable),
    .cs1(cs1),
    .cs2(cs2),
    .data(data),
    .password(password),
    .num_ingresados(npuntero_digitos),
    .pass_incorrecta(incorrect_password)
);

assign correct_password = ~ncorrect_password;
assign puntero_digitos = ~npuntero_digitos;
    
endmodule
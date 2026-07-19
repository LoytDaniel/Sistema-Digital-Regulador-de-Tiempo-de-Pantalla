module Keyboard_top (
    input clk, reset,
    input [3:0] col,
    output [3:0] row,
    output [3:0] key_out, //key_in,
    output push_button,
	 output Aceptar, Borrar, Salir,//, is_digit
	 output clk1
);


wire contar;
wire [1:0] count;
wire [1:0] row_reg;
wire [3:0] key_in;
wire [3:0] col_reg, key;
wire scan, delay, decoder;
wire esperar, decodificar;

//logica negada
wire nreset, npush_button;
wire [3:0] nrow, ncol, nkey_out, key_c;

assign nreset=~reset;


clock clk_div (
    .clk(clk),
    .reset(nreset),
    .count(clk1)
);

assign ncol=~col;

Matrix_4x4 mat1 (
    .counter(count),
    .col_in(ncol),
    .clk(clk1),
    .value_detected(scan),
    .row_out(nrow),
    .col_reg(col_reg),
    .row_reg(row_reg)
);

counter c2 (
        .clk(clk1),
        .contar(contar),
        .reset(nreset),
        .count(count)
    );

assign row=~nrow;

decodificador dec (
    .clk(clk1),
    .reset(nreset),
    .row_reg(row_reg),
    .col_cleaned(col_reg),
    .decodificar(decodificar),
    .decoder(decoder),
    .salida(key_in)
);

debounce db (
    .clk(clk1),
    .reset(nreset),
    .key_in(key_in),
    .scan(scan),
    .esperar(esperar),
    .delay(delay),
    .key_out(key_c)
);

FSM_teclado fsm (
    .clk(clk1),
    .reset(nreset),

    .scan(scan),
    .decoder(decoder),
    .delay(delay),

    .contar(contar),
    .decodificar(decodificar),
    .esperar(esperar)
);


Special_keys sk(
	.key_in(key_c), 
    .push_button(delay),
   .accept_key(nAceptar),
   .delete_key(nBorrar),
   .exit_key(nSalir),
    .key_out(nkey_out),
   .key_enable(npush_button)
);


/*
decodTeclas dt (
    .key_in(key_in),
   .push_button(npush_button), 
   .Aceptar(nAceptar),
   .Borrar(nBorrar),
   .Salir(nSalir),
   .is_digit(is_digit)
);
*/

assign key_out= nkey_out;//nkey_out;
assign push_button = npush_button;
assign Aceptar = nAceptar;
assign Borrar = nBorrar;
assign Salir = nSalir;
 
endmodule
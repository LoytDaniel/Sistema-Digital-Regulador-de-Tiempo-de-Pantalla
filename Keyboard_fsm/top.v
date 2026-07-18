module top (
    input clk, reset,
    input [3:0] col,
	 
	 
	 
	 
	 
	 input password,
	 
	 
	 

    output [3:0] row,
    output [3:0] key_out,
    output push_button,
	 output Aceptar, Borrar, Salir,
	 
	 
	 
	 output correct_password, exit,
	 output [2:0] puntero_digitos
	 
	 
	 
	 
	 
	 
	 
);

wire clk1, contar;
wire [1:0] count;
wire [1:0] row_reg;
wire [3:0] key_in;
wire [3:0] col_reg;
wire scan, delay, decoder;
wire esperar, decodificar;

wire nAceptar, nBorrar, nSalir;


//logica negada
wire nrest, npush_button;
wire [3:0] nrow, ncol, nkey_out;







wire npassword;



wire ncorrect_password, nexit;
wire [2:0] npuntero_digitos;









assign npassword =~ password;


assign nreset=~reset;
assign npush_button=delay;



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
    .esperar(esperar),
    .delay(delay),
    .key_out(nkey_out)
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


decodTeclas dt (
	.key_in(key_in),
   .push_button(npush_button), 
   .Aceptar(nAceptar),
   .Borrar(nBorrar),
   .Salir(nSalir)
);

password_menu pm(
	.clk(clk1),
	.rst(nreset),
	.password(npassword),
	.key_out(key_in),
	.push_button(npush_button),
	.Aceptar(nAceptar),
	.Borrar(nBorrar),
	.Salir(nSalir),
	.correct_password(ncorrect_password),
	.exit(nexit),
	.puntero_digitos(npuntero_digitos)
	
);


assign key_out=~nkey_out;
assign push_button =~ npush_button;
assign Aceptar =~ nAceptar;
assign Borrar =~ nBorrar;
assign Salir =~ nSalir;



assign correct_password =~ ncorrect_password;
assign exit =~ nexit;
assign puntero_digitos =~ npuntero_digitos;

 
endmodule
/*`timescale 1ns / 1ps
//======================================================================

module password_menu #(
    parameter [15:0] DEFAULT_PASSWORD = 16'h1234 // Contrasena por defecto: digitos D3 D2 D1 D0
)(
    input  wire clk,
    input  wire rst,            

    input  wire password,       //Enable de la FSM para este modulo
    input  wire [3:0] key_out,        //Valor en BCD dado por el teclado
    input  wire push_button,    //Señal de que se está presionando un boton
    input  wire Aceptar,        
    input  wire Borrar,
    //input is_digit,        
    output reg correct_password, incorrect_password,  //Bandera para que la FSM cambie a otra pestaña              
    output reg [2:0] puntero_digitos     //Indicador para la pantalla LED
);

////////////////////////////////////////////////////////////////////////////////////////////
    // Mecanismo para evitar que tome varios datos con un solo pulso
    reg push_button_d, Aceptar_d, Borrar_d;

    always @(posedge clk) begin
        if (rst) begin
            push_button_d <= 1'b0;
            Aceptar_d <= 1'b0;
            Borrar_d <= 1'b0;
        end else begin
            push_button_d <= push_button;
            Aceptar_d <= Aceptar;
            Borrar_d <= Borrar;
        end
    end

    wire push_button_re = push_button & ~push_button_d; 
    wire Aceptar_re = Aceptar & ~Aceptar_d;     
    wire Borrar_re = Borrar & ~Borrar_d;             

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Asignación de valores a los digitos
    wire is_digit;
    assign is_digit = (key_out <= 4'd9);  // Me dice si es un digito ya que el teclado por default a las letras arroja 1111
    reg [3:0] D3, D2, D1, D0;
    wire acepta_digito = password && push_button_re && is_digit && (puntero_digitos < 3'd4);                  // Muestra todas las condiciones que se debe cumplir para que se guarde el dato en cada uno de los digitos

    always @(posedge clk) begin
        if (rst || !password) begin
            D3 <= 4'd0; D2 <= 4'd0; D1 <= 4'd0; D0 <= 4'd0;
            puntero_digitos <= 3'd0;
        end else if (Borrar_re) begin
            D3 <= 4'd0; D2 <= 4'd0; D1 <= 4'd0; D0 <= 4'd0;
            puntero_digitos <= 3'd0;
        end else if (acepta_digito) begin
            case (puntero_digitos)
                3'd0: D3 <= key_out; // primer digito ingresado
                3'd1: D2 <= key_out; // segundo digito
                3'd2: D1 <= key_out; // tercer digito
                3'd3: D0 <= key_out; // cuarto digito
                default: ; 
            endcase
            puntero_digitos <= puntero_digitos + 3'd1;
        end
    end

    wire [15:0] entered_password = {D3, D2, D1, D0};

////////////////////////////////////////////////////////////////////////////////////////

// Verificación de contraseña

    always @(posedge clk) begin
        if (rst) begin
            correct_password <= 1'b0;
            incorrect_password <= 1'b0;
        end else if (password && Aceptar_re) begin
            correct_password <= (entered_password == DEFAULT_PASSWORD);
            incorrect_password <= (entered_password != DEFAULT_PASSWORD);
        end else begin
            correct_password <= 1'b0; // Se mantiene como pulso de 1 ciclo
        end
    end
/////////////////////////////////////////////////////////////////////////////////////////////

endmodule*/

`timescale 1ns / 1ps
//======================================================================

module password_menu #(
    parameter [15:0] DEFAULT_PASSWORD = 16'h1234 // Contrasena por defecto: digitos D3 D2 D1 D0
)(
    input  wire       clk,
    input  wire       rst,            

    input  wire       password,       //Enable de la FSM para este modulo
    input  wire [3:0] key_out,        //Valor en BCD dado por el teclado
    input  wire       push_button,    //Señal de que se está presionando un boton
    input  wire       Aceptar,        
    input  wire       Borrar,             
    output reg        correct_password, incorrect_password, //Bandera para que la FSM cambie a otra pestaña             
    output reg [2:0]  puntero_digitos,     //Indicador para la pantalla LED
	 output [3:0] d1, d2, d3, d0
);

////////////////////////////////////////////////////////////////////////////////////////////
    // Mecanismo para evitar que tome varios datos con un solo pulso
  
  
		
	/*reg [$clog2(COUNT_MAX)-1:0] clk_counter;
	reg clk_10ms;

	always @(posedge clk) begin
		if (clk_counter == COUNT_MAX - 1) begin
			clk_10ms <= ~clk_10ms;
			clk_counter <= 'b0;
		end else begin
        clk_counter <= clk_counter + 1;
		end
	end
	*/
	
	reg [3:0] key_in;
	reg push_button_d, Aceptar_d, Borrar_d;
    reg push_button_sync1, push_button_sync2;
	 reg Aceptar_sync1, Aceptar_sync2;
	 reg Borrar_sync1, Borrar_sync2;

	always @(posedge clk or posedge rst) begin
		 if (rst) begin
			  push_button_sync1 <= 1'b0;
			  push_button_sync2 <= 1'b0;
			  Aceptar_sync1 <= 1'b0; 
			  Aceptar_sync2 <= 1'b0;
			  Borrar_sync1 <= 1'b0;
			  Borrar_sync2 <= 1'b0;
		 end else begin
				key_in <= key_out;
			    push_button_sync1 <= push_button;       // 1ra etapa: puede quedar metaestable, y no pasa nada
			    push_button_sync2 <= push_button_sync1; // 2da etapa: ya estable, segura de usar
                Aceptar_sync1 <= Aceptar;       // 1ra etapa: puede quedar metaestable, y no pasa nada
                Aceptar_sync2 <= Aceptar_sync1; // 2da etapa: ya estable, segura de usar
                Borrar_sync1 <= Borrar;       // 1ra etapa: puede quedar metaestable, y no pasa nada
                Borrar_sync2 <= Borrar_sync1; // 2da etapa: ya estable, segura de usar
		 end
	end

// Ahora tu detector de flanco usa la señal ya sincronizada, no la cruda

	always @(posedge clk) begin
		 if (rst) begin
            push_button_d <= 1'b0;
            Aceptar_d     <= 1'b0;
            Borrar_d      <= 1'b0;
         end
		 else begin
            push_button_d <= push_button_sync2;
            Aceptar_d     <= Aceptar_sync2;
            Borrar_d      <= Borrar_sync2;
         end
	end

	wire push_button_re = push_button_sync2 & ~push_button_d;
    wire Aceptar_re     = Aceptar_sync2     & ~Aceptar_d;     
    wire Borrar_re      = Borrar_sync2      & ~Borrar_d;       
/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Asignación de valores a los digitos
    reg [3:0] D3, D2, D1, D0;
	 assign d1=~D1;
	 assign d2=~D2;
	 assign d3=~D3;
	 assign d0=~D0;

    wire is_digit      = (key_out <= 4'd9);                         // Me dice si es un digito ya que el teclado por default a las letras arroja 1111
    wire acepta_digito = password && push_button_re && is_digit && (puntero_digitos < 3'd4);                  // Muestra todas las condiciones que se debe cumplir para que se guarde el dato en cada uno de los digitos

    always @(posedge clk) begin
        if (rst || !password) begin
            D3 <= 4'd0; D2 <= 4'd0; D1 <= 4'd0; D0 <= 4'd0;
            puntero_digitos <= 3'd0;
        end else if (Borrar_re) begin
            D3 <= 4'd0; D2 <= 4'd0; D1 <= 4'd0; D0 <= 4'd0;
            puntero_digitos <= 3'd0;
        end else if (acepta_digito) begin
            case (puntero_digitos)
                3'd0: D3 <= key_in; // primer digito ingresado
                3'd1: D2 <= key_in; // segundo digito
                3'd2: D1 <= key_in; // tercer digito
                3'd3: D0 <= key_in; // cuarto digito
                default: ; 
            endcase
            puntero_digitos <= puntero_digitos + 3'd1;
        end
    end

    wire [15:0] entered_password = {D3, D2, D1, D0};


////////////////////////////////////////////////////////////////////////////////////////

// Verificación de contraseña

    always @(posedge clk) begin
        if (rst) begin
            correct_password <= 1'b0;
            incorrect_password <= 1'b0;
        end else if (password && Aceptar) begin
            correct_password = (entered_password == DEFAULT_PASSWORD);
            incorrect_password = (entered_password != DEFAULT_PASSWORD);
        end else begin
            correct_password <= 1'b0; // Se mantiene como pulso de 1 ciclo
        end
    end

/////////////////////////////////////////////////////////////////////////////////////////////

endmodule

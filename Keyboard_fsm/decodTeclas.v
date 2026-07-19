module decodTeclas (
    input [3:0] key_in,
    input push_button, 
    output reg  Aceptar,
    output reg Borrar,
    output reg Salir,
    output is_digit
);

 assign is_digit = (key_in <= 4'd9);  // Me dice si es un digito ya que el teclado por default a las letras arroja 1111

    always @(*) begin
      
        Aceptar = 1'b0;
        Borrar = 1'b0;
        Salir = 1'b0;

        if (push_button) begin
            if (key_in == 4'd10)
                Aceptar = 1'b1; // tecla 'A'
            else if (key_in == 4'd11)
                Borrar = 1'b1;  // tecla 'B'
            else if (key_in == 4'd14)
                Salir = 1'b1;   // tecla '*'
        end
    end

endmodule
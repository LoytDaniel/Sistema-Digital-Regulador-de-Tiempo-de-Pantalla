module encoder_matriz (
    input [3:0]key_value,
    input push_button,
    output reg [3:0]encoded_value
    
);
// Esto deberia de codificar a que? a ascii? a BCD? a un codigo propio? quedo como uno propio :)

// No se, toma mirar el valor para aceptar, cancelar y moverse :)
always @(*) begin
    if (push_button) begin
        case (key_value)
        4'b0000: encoded_value <= 4'b0001; // Tecla 1
        4'b0001: encoded_value <= 4'b0010; // Tecla 2
        4'b0010: encoded_value <= 4'b0011; // Tecla 3
        4'b0100: encoded_value <= 4'b0100; // Tecla 4
        4'b0101: encoded_value <= 4'b0101; // Tecla 5
        4'b0110: encoded_value <= 4'b0110; // Tecla 6
        4'b1000: encoded_value <= 4'b0111; // Tecla 7
        4'b1001: encoded_value <= 4'b1000; // Tecla 8
        4'b1010: encoded_value <= 4'b1001; // Tecla 9
        4'b1101: encoded_value <= 4'b0000; // Tecla 0
        default: encoded_value <= 4'b1111; // Ninguna tecla válida presionada
        endcase
    end else begin
        encoded_value <= 4'b1111; // Ninguna tecla presionada, valor por defecto
    end
    
end
endmodule
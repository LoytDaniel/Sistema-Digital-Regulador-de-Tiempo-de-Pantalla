module debounce (
    input clk, reset,
    input [3:0] key_in,
    input esperar,

    output reg delay,
    output reg [3:0] key_out
);

reg [5:0] counter; // Contador de 20 bits para generar un retardo de aproximadamente 10 ms
reg [3:0] key_reg; // Registro para almacenar la tecla actual


always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 0;
        key_out <= 4'b0000; // Reinicia la salida a 0
        delay <= 0; // Reinicia la señal de retardo
        key_reg <= 4'b0000; // Reinicia el registro de la tecla
    end else if (esperar) begin
        if (counter == 6'b0) begin
            key_reg <= key_in;
            key_out <= key_in; // Actualiza la salida con la tecla actual
            delay=0;
            counter <= counter + 1; // Incrementa el contador
        end
        if (counter < 6'd20) begin
            counter <= counter + 1; // Incrementa el contador
        end else begin
            delay <= 1; // Activa la señal de retardo después de alcanzar el valor máximo
            counter <= 0; // Reinicia el contador para la próxima tecla
        end
    end
end



endmodule
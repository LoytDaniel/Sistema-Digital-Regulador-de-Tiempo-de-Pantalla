module matriz_4x4 (
    input [3:0]column,
    input clk, reset,
    output reg push_button,
    output reg [3:0]row,
    output reg [3:0]key_value
);
    /* Con este se pretende muestrear cada fila de la matriz de manera secuencial, y dependiendo de la 
    columna que se active, se asigna un valor a key_value que representa la tecla presionada. 
    El contador se utiliza para cambiar la fila activa cada cierto tiempo, lo que permite detectar 
    múltiples teclas presionadas en diferentes filas.
    Se le asigna un numero del 0 al 15 a cada tecla, dependiendo de la fila y columna que se active.
    El valor de push_button se asigna a 1 cuando se detecta una tecla presionada, y a 0 cuando no se detecta ninguna tecla.
    */
    wire clk1;
    wire [1:0] counter;
    clock cl (.clk(clk), .reset(reset), .count(clk1));
    counter c1 (.clk(clk1), .reset(reset), .count(counter));

    always @(posedge clk) begin
        case (counter)
        2'b00: row <= 4'b0001; // Activa la primera fila
        2'b01: row <= 4'b0010; // Activa la segunda fila
        2'b10: row <= 4'b0100; // Activa la tercera fila
        2'b11: row <= 4'b1000; // Activa la cuarta fila
        endcase
    end

    always @(*) begin
        push_button <= 1'b1; // Inicializa push_button a 1
        case (column)
        4'b0001: key_value <= {counter, 2'b00}; // Columna 1
        4'b0010: key_value <= {counter, 2'b01}; // Columna 2
        4'b0100: key_value <= {counter, 2'b10}; // Columna 3
        4'b1000: key_value <= {counter, 2'b11}; // Columna 4
        default: push_button <= 1'b0; // Ninguna tecla presionada
        endcase
    end

endmodule
module debounce (
    input clk, reset,
    input [3:0] key_in,
    input esperar,
    input scan,                 // señal de Matrix_4x4: sigue en 1 mientras la tecla está físicamente presionada
    output reg delay,
    output reg [3:0] key_out
);

    localparam ESTABLE_CNT = 6'd20; // ciclos de clk1 para filtrar el rebote

    reg [5:0] counter;
    reg [3:0] key_reg;
    reg confirmado; // 1 = ya se filtró el rebote y se capturó la tecla; falta esperar liberación

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter    <= 0;
            key_out    <= 4'hf;
            key_reg    <= 4'hf;
            delay      <= 1'b0;
            confirmado <= 1'b0;
        end else if (esperar) begin
            if (!confirmado) begin
                // --- Fase 1: filtrar rebote ---
                if (counter == 6'd0)
                    key_reg <= key_in;

                if (counter < ESTABLE_CNT) begin
                    counter <= counter + 1;
                end else begin
                    key_out    <= key_reg; // se captura UNA sola vez
                    confirmado <= 1'b1;    // pasa a esperar liberación
                    counter    <= 0;
                end
            end else begin
                // --- Fase 2: esperar liberación ---
                //if (scan) //-> esto no sirve porque scan deja de ser 1 cuando se detiene el contador
                    delay <= 1'b1; // recién aquí se le avisa a la FSM que puede salir de DEBOUNCE
            end
        end else begin
            // esperar = 0: se reinicia todo para la próxima tecla 
            counter    <= 0;
            delay      <= 1'b0;
            confirmado <= 1'b0;
        end
    end

endmodule
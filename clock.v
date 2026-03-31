///Aparentemente la frecuencia del reloj de la FPGA es de 50 MHz
module clock (
    input clk,
    input reset,
    output reg count
);
integer cuenta;

always @(posedge clk) begin
    if (reset) begin
        cuenta <= 0;
        count <= 0;
    end
    else begin
        if (cuenta == 833334) begin // Ajustar este valor para tener una frec de 60 Hz
            count <= ~count; // Cambia el estado del contador
            cuenta <= 0; // Reinicia la cuenta
        end
        else
        cuenta <= cuenta + 1;
    end
end


endmodule
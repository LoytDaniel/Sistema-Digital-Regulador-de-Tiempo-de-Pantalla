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
        if (cuenta == 1000000) begin // Ajustar este valor para el debounce deseado (cuenta hasta 1 mill o 75 mill si se deja 1.5s)
            count <= ~count; // Cambia el estado del contador
            cuenta <= 0; // Reinicia la cuenta
        end
        else
        cuenta <= cuenta + 1;
    end
end


endmodule
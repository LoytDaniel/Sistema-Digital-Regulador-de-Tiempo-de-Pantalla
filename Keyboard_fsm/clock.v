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
        if (cuenta == 250000) begin //vamos a dejarlo de 1 ms
            count <= ~count; // Cambia el estado del contador
            cuenta <= 0; // Reinicia la cuenta
        end
        else
        cuenta <= cuenta + 1;
    end
end


endmodule
module decodificador (
    input clk, reset,
    input decodificar,
    input [1:0] row_reg,
    input [3:0] col_cleaned,

    output reg decoder,
    output reg [3:0] salida
);
    
always @(posedge clk) begin
    if (reset) begin
        salida <= 4'b0000; // Reinicia la salida a 0
        decoder <= 0; // Reinicia la señal de decodificación
    end else if (decodificar) begin
        decoder <= 1; // Activa la señal de decodificación
        case ({row_reg, col_cleaned})
        
            {2'b00, 4'b0001}: salida <= 4'h1;
            {2'b00, 4'b0010}: salida <= 4'h2;
            {2'b00, 4'b0100}: salida <= 4'h3;
            {2'b00, 4'b1000}: salida <= 4'hA; //Accept

            {2'b01, 4'b0001}: salida <= 4'h4;
            {2'b01, 4'b0010}: salida <= 4'h5;
            {2'b01, 4'b0100}: salida <= 4'h6;
            {2'b01, 4'b1000}: salida <= 4'hB; //Delete

            {2'b10, 4'b0001}: salida <= 4'h7;
            {2'b10, 4'b0010}: salida <= 4'h8;
            {2'b10, 4'b0100}: salida <= 4'h9;
            {2'b10, 4'b1000}: salida <= 4'hF;

            {2'b11, 4'b0001}: salida <= 4'hE;
            {2'b11, 4'b0010}: salida <= 4'h0;
            {2'b11, 4'b0100}: salida <= 4'hF;
            {2'b11, 4'b1000}: salida <= 4'hF;

             // aqui poner las otras dos teclas para aceptar y cancelar
            default: salida <= salida; // Ninguna tecla presionada o combinación no válida
        endcase
    end else begin

        salida <= salida; // Mantiene el valor actual si no se está decodificando
        decoder <= 0; // Desactiva la señal de decodificación

    end
end
endmodule
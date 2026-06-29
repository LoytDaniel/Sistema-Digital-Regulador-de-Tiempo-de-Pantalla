module counter (
    input clk, reset, contar,
    output reg [1:0] count
);
    
    always @(posedge clk) begin //se activa en el flanco positivo del reloj o cuando se activa el reset
        if (reset)
            count = 0; //comience desde 0
        else if (contar)
            count = count + 1; //incrementa el contador en cada flanco positivo del reloj
    end
endmodule
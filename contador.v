module counter (
    input clk, reset,
    output [1:0] cont
);
    
    always @(posedge clk) begin //se activa en el flanco positivo del reloj o cuando se activa el reset
        if (reset)
            cont = 0; //comience desde 0
        else
            cont = cont + 1; //incrementa el contador en cada flanco positivo del reloj
    end

endmodule
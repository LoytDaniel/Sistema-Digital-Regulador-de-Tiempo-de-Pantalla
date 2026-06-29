module FSM_teclado (
    input clk,
    input reset,
    //ENTRADAS
    input scan,
    input decoder,
    input delay,

    output reg decodificar,
    output reg esperar,
    output reg contar
    //SALIDAS
);
    
localparam IDLE = 2'b00;
localparam SCAN = 2'b01;
localparam DEBOUNCE = 2'b10; //nose

reg [1:0] state, next_state;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end


//logica de transicion de estados
always @(*) begin
    next_state = state; 
    case (state)
        IDLE: begin
            if (scan) begin
                next_state = SCAN;
            end else next_state = IDLE;
        end

        SCAN: begin
            if (decoder) begin
                next_state = DEBOUNCE;
            end else next_state = SCAN;
        end

        DEBOUNCE: begin
            if (delay) begin
                next_state = IDLE;
            end else next_state = DEBOUNCE;
        end

        
        
    endcase
end

//logica de salida
always @(*) begin
    case (state)
        IDLE: begin
            contar=1;
            esperar=0;
            decodificar=0;
        end

        DEBOUNCE: begin
            esperar=1;
            decodificar=0;
            contar=0;
        end

        SCAN: begin
            decodificar=1;
            esperar=0;
            contar=0;
        end

    endcase
end

endmodule
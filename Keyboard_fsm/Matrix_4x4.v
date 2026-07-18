module Matrix_4x4(
    input [1:0]counter,
    input [3:0] col_in,
    input clk,

    output reg value_detected,
    output reg [3:0] row_out,
    output reg [3:0] col_reg,
    output reg [1:0] row_reg
);

always @(posedge clk) begin

    case (counter)
        2'b00: row_out <= 4'b0001;
        2'b01: row_out <= 4'b0010;
        2'b10: row_out <= 4'b0100;
        2'b11: row_out <= 4'b1000;
    endcase

    if (col_in != 4'b0000) begin//((col_in == 4'b0001) || (col_in == 4'b0010) || (col_in == 4'b0100) || (col_in == 4'b1000)) begin
        value_detected <= 1;
        col_reg <= col_in;      // Captura la columna detectada
        row_reg <= (counter-1);     // Captura la fila actual
    end else begin
        value_detected <= 0;
        // Los valores se mantienen gracias a los registros (<=)
    end
end
    
endmodule
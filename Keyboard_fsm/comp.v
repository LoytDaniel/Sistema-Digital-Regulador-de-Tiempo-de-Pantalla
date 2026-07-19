module comp(
    input [3:0] key_in,
    input delay,
    output reg enable,
    output reg [3:0] key_out
);

reg [3:0] key_reg;

always @(posedge delay)begin
    if (key_in != key_reg) begin
        enable <= 1;
        key_out <= key_reg;
        key_reg <= key_in;
    end else begin
        enable <= 0;
    end
end

endmodule
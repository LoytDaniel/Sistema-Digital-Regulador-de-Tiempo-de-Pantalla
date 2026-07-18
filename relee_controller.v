module relee_controller (
    input kids,
    input time_finish,
    output reg off_enable
);

always @(*) begin
    if (kids && time_finish) begin
        off_enable = 1'b1;
    end else begin
        off_enable = 1'b0;
    end
end 
 
endmodule
module select_menu (
    input menu,
    input [3:0] key_value,
    output reg [1:0] options
);
    
always @(*) begin
    if (menu) begin
       case (key_value)
        4'b0001 : options = 2'b01;
        4'b0010 : options = 2'b10;
        default: options = 2'b00;
       endcase 
    end
end


endmodule
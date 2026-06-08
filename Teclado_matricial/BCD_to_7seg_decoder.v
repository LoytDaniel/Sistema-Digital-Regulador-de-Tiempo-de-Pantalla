module BCD_to_7seg_decoder (bcd, deg);

input  [3:0] bcd;
output  reg [6:0] deg;
//reg [3:0] nbcd; // Lógica negativa del BCD

always @(bcd)
  begin
  //nbcd=(~bcd); //esto porque trabaja con lógica negativa
    case (bcd)
        4'b0000: deg=7'b1111110; //Cero
        4'b0001: deg=7'b0110000; //uno
        4'b0010: deg=7'b1101101; //Dos
        4'b0011: deg=7'b1111001; //Tres
        4'b0100: deg=7'b0110011; //Cuatro
        4'b0101: deg=7'b1011011; //Cinco
        4'b0110: deg=7'b1011111; //seis
        4'b0111: deg=7'b1110000; //Siete
        4'b1000: deg=7'b1111111; //Ocho
        4'b1001: deg=7'b1111011; //Nueve
        default: deg=7'b000000; //no hacer nada
    endcase
	 //deg=~deg;//esto porque trabaja con lógica negativa
  end
  
endmodule
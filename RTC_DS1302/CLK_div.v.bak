module CLK_div (clk_in, clk_out);  // Reloj con frecuencia de 1 MHz para el módulo RTC_DS1302, asumiendo que el reloj de la FPGA es de 50 MHz
	
	input clk_in;
	output clk_out;
	
	integer DIVISOR = 5'd25;
	
	reg [4:0] count;
	
	always @(posedge clk_in) begin
		count <= count + 5'd1;
			if (count == DIVISOR) begin
				count <= 0;
				clk_out <= ~clk_out;
			end
	end
	
endmodule 
		
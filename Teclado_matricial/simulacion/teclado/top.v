module top (
    input clk, reset,
    input [3:0] column,
	 output bitON,
    output [3:0] row,
    output [6:0] seg
);
    wire [3:0] key_value, encoded_value, ncolumn, nrow;
	 wire [6:0] nseg;
	 wire nreset;
	 
	 assign nreset=~reset;
	 not (bitON, 1'b1);
	 assign ncolumn=~column;
	 
    matriz_4x4 m1 (
        .column(ncolumn),
        .clk(clk),
        .reset(nreset),
        .push_button(push_button),
        .row(nrow),
        .key_value(key_value)
    );
	 
	 assign row=~nrow;

    encoder_matriz e1 (
        .key_value(key_value),
        .push_button(push_button),
        .encoded_value(encoded_value)
    );
    
    BCD_to_7seg_decoder s1 (
        .bcd(encoded_value),
        .deg(nseg)
    );
	assign seg=~nseg;

endmodule
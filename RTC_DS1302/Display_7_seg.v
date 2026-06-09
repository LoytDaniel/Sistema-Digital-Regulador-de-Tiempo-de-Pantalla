module Display_7_seg #(
	parameter CYCLES_PER_DIGIT = 8333
)(
	input clk, rstn,
	input [7:0] hr, min, sec, // in BCD	
	output reg [6:0] seg,
    output reg [5:0] bitON
);
	
    reg [6:0] HEX [0:5];
    reg [2:0] count = 0;
    reg tick;
    integer clk_counter = 0;

    localparam ZERO = 7'b0111111; //Cero
    localparam ONE = 7'b0000110; //uno
    localparam TWO = 7'b1011011; //Dos
    localparam THREE = 7'b1001111; //Tres
    localparam FOUR = 7'b1100110; //Cuatro
    localparam FIVE = 7'b1101101; //Cinco
    localparam SIX = 7'b1111101; //seis
    localparam SEVEN = 7'b0000111; //Siete
    localparam EIGHT = 7'b1111111; //Ocho
    localparam NINE = 7'b1100111; //Nueve
    localparam DASH = 7'b1000000; //Guion

	// Tens digit of hour
	always @(*) begin
		case ({2'b00, hr[5:4]})
			4'd0: HEX[5] = ZERO; 
			4'd1: HEX[5] = ONE; 
			4'd2: HEX[5] = TWO; 
			4'd3: HEX[5] = THREE; 
			4'd4: HEX[5] = FOUR; 
			4'd5: HEX[5] = FIVE; 
			4'd6: HEX[5] = SIX; 
			4'd7: HEX[5] = SEVEN; 
			4'd8: HEX[5] = EIGHT; 
			4'd9: HEX[5] = NINE; 
			default: HEX[5] = DASH;
		endcase
	end 
	
	// Ones digit of hour
	always @(*) begin
		case (hr[3:0])
			4'd0: HEX[4] = ZERO; 
			4'd1: HEX[4] = ONE; 
			4'd2: HEX[4] = TWO; 
			4'd3: HEX[4] = THREE; 
			4'd4: HEX[4] = FOUR; 
			4'd5: HEX[4] = FIVE; 
			4'd6: HEX[4] = SIX; 
			4'd7: HEX[4] = SEVEN; 
			4'd8: HEX[4] = EIGHT; 
			4'd9: HEX[4] = NINE; 
			default: HEX[4] = DASH;
		endcase
	end 
	
	// Tens digit of minute
	always @(*) begin
		case ({1'b0, min[6:4]})
			4'd0: HEX[3] = ZERO; 
			4'd1: HEX[3] = ONE; 
			4'd2: HEX[3] = TWO; 
			4'd3: HEX[3] = THREE; 
			4'd4: HEX[3] = FOUR; 
			4'd5: HEX[3] = FIVE; 
			4'd6: HEX[3] = SIX; 
			4'd7: HEX[3] = SEVEN; 
			4'd8: HEX[3] = EIGHT; 
			4'd9: HEX[3] = NINE; 
			default: HEX[3] = DASH;
		endcase
	end 
	
	// Ones digit of minute
	always @(*) begin
		case (min[3:0])
			4'd0: HEX[2] = ZERO; 
			4'd1: HEX[2] = ONE; 
			4'd2: HEX[2] = TWO; 
			4'd3: HEX[2] = THREE; 
			4'd4: HEX[2] = FOUR; 
			4'd5: HEX[2] = FIVE; 
			4'd6: HEX[2] = SIX; 
			4'd7: HEX[2] = SEVEN; 
			4'd8: HEX[2] = EIGHT; 
			4'd9: HEX[2] = NINE; 
			default: HEX[2] = DASH;
		endcase
	end 
	
	// Tens digit of second
	always @(*) begin
		case ({1'b0, sec[6:4]})
			4'd0: HEX[1] = ZERO; 
			4'd1: HEX[1] = ONE; 
			4'd2: HEX[1] = TWO; 
			4'd3: HEX[1] = THREE; 
			4'd4: HEX[1] = FOUR; 
			4'd5: HEX[1] = FIVE; 
			4'd6: HEX[1] = SIX; 
			4'd7: HEX[1] = SEVEN; 
			4'd8: HEX[1] = EIGHT; 
			4'd9: HEX[1] = NINE; 
			default: HEX[1] = DASH;
		endcase
	end 
	
	// Ones digit of second
	always @(*) begin
		case (sec[3:0])
			4'd0: HEX[0] = ZERO; 
			4'd1: HEX[0] = ONE; 
			4'd2: HEX[0] = TWO; 
			4'd3: HEX[0] = THREE; 
			4'd4: HEX[0] = FOUR; 
			4'd5: HEX[0] = FIVE; 
			4'd6: HEX[0] = SIX; 
			4'd7: HEX[0] = SEVEN; 
			4'd8: HEX[0] = EIGHT; 
			4'd9: HEX[0] = NINE; 
			default: HEX[0] = DASH;
		endcase
	end

always @(posedge clk) begin
	if (!rstn) begin
		clk_counter <= 0;
		tick <= 0;
	end else if (clk_counter == CYCLES_PER_DIGIT) begin
		tick <= 1;
		clk_counter <= 0;
	end else begin
		tick <= 0;
		clk_counter <= clk_counter + 1;
	end
end

always @(posedge clk) begin
    if (tick) begin  // solo avanza cada CYCLES_PER_DIGIT ciclos
        if (count == 5) count <= 0;
        else count <= count + 1;

        case (count)
            3'd0: begin seg = HEX[0]; bitON = 6'b000001; end
            3'd1: begin seg = HEX[1]; bitON = 6'b000010; end
            3'd2: begin seg = HEX[2]; bitON = 6'b000100; end
            3'd3: begin seg = HEX[3]; bitON = 6'b001000; end
            3'd4: begin seg = HEX[4]; bitON = 6'b010000; end
            3'd5: begin seg = HEX[5]; bitON = 6'b100000; end
        endcase
    end
end

endmodule 
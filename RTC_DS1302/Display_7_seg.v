module Display_7_seg (clk, hr, min, sec, seg, bitON);
	
	input reg clk;
	input reg [7:0] hr, min, sec; // in BCD	
	output reg [6:0] seg;
    output reg [2:0] bitON;
	
    reg [6:0] HEX [0:5];
    reg [2:0] count;
    reg clk_divider;
    integer clk_counter = 0;

    localparam ZERO = 7'b1111110; //Cero
    localparam ONE = 7'b0110000; //uno
    localparam TWO = 7'b1101101; //Dos
    localparam THREE = 7'b1111001; //Tres
    localparam FOUR = 7'b0110011; //Cuatro
    localparam FIVE = 7'b1011011; //Cinco
    localparam SIX = 7'b1011111; //seis
    localparam SEVEN = 7'b1110000; //Siete
    localparam EIGHT = 7'b1111111; //Ocho
    localparam NINE = 7'b1111011; //Nueve
    localparam DASH = 7'b0000001; //Guion

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
        if (clk_counter == 104166) begin
            clk_divider <= ~clk_divider;
            clk_counter <= 0;
        end else begin
            clk_counter <= clk_counter + 1;
        end
    end
	
    always @(posedge clk_divider)
        begin
            case (count)
                0: begin
                    seg=HEX[0];
                    bitON=3'b001;
                end
                1: begin
                    seg=HEX[1];
                    bitON=3'b010;
                end
                2: begin
                    seg=HEX[2];
                    bitON=3'b011;
                end 
                3: begin
                    seg=HEX[3];
                    bitON=3'b100;
                end
                4: begin
                    seg=HEX[4];
                    bitON=3'b101;
                end
                5: begin
                    seg=HEX[5];
                    bitON=3'b110;
                end
            endcase
        end

endmodule 
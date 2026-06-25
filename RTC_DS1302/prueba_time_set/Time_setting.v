module Time_setting (clk, rstn, ext_input, set, hr, min, sec, hr_en, min_en, sec_en);

	input clk, rstn, set;
	input [5:0] ext_input;
	
	output reg [4:0] hr;
	output reg [5:0] min, sec;
	
   output reg hr_en, min_en, sec_en;
	
	reg [1:0] state, next_state;
	reg prev_set;
	
    // State encoding for the state machine
    localparam SET_HR = 2'b00;
    localparam SET_MIN = 2'b01;
    localparam SET_SEC = 2'b10;
    localparam IDLE = 2'b11;

    // Update hr, min, sec based on the external input
	always @(posedge clk) begin
		if (!rstn) begin
			hr <= 5'd0;
			min <= 6'd0;
			sec <= 6'd0;
		end else begin
			// Set the hr, min, or sec to the value from the external switches input when the corresponding enable signal is HIGH
			if (hr_en) begin
				if (ext_input > 5'd24) hr <= 5'd23; // Max hour is 23, even if inputting greater number
				else hr <= ext_input;
			end
			else if (min_en) begin
				if (ext_input > 6'd59) min <= 6'd59; // Max minute is 59, even if inputting greater number
				else min <= ext_input;
			end
			else if (sec_en) begin
				if (ext_input > 6'd59) sec <= 6'd59; // Max second is 59, even if inputting greater number
				else sec <= ext_input;
			end
		end
	end
	
	// Detect falling edge of set button
	always @(posedge clk) begin
		if (set) prev_set <= 1;
		else if (prev_set) prev_set <= 0;
	end
	
    // State transition logic for the state machine
	always @(posedge clk) begin
		if (!rstn) state <= IDLE;
		else state <= next_state;
	end
	
	always @(*) begin
		case (state)

			SET_HR: begin
				if (!set && prev_set) next_state = SET_MIN;
				else next_state = SET_HR;
			end
				
			SET_MIN: begin
				if (!set && prev_set) next_state = SET_SEC;
				else next_state = SET_MIN;
			end
				
			SET_SEC: begin
				if (!set && prev_set) next_state = IDLE;
				else next_state = SET_SEC;
			end
				
			IDLE: begin
				if (!set && prev_set) next_state = SET_HR;
				else next_state = IDLE;
			end
				
			default: next_state = IDLE;
		endcase
	end
	
	// Output logic
	always @(*) begin
		case (state)
			SET_HR: begin
				hr_en = 1;
				min_en = 0;
				sec_en = 0;
			end
				
			SET_MIN: begin
				hr_en = 0;
				min_en = 1;
				sec_en = 0;
			end
				
			SET_SEC: begin
				hr_en = 0;
				min_en = 0;
				sec_en = 1;
			end
				
			IDLE: begin
				hr_en = 0;
				min_en = 0;
				sec_en = 0;
			end
				
			default: begin
				hr_en = 0;
				min_en = 0;
				sec_en = 0;
			end
		endcase
	end
	
endmodule 
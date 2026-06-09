module Bin_to_BCD (hr_in, min_in, sec_in, hr_out, min_out, sec_out);
	
	input [5:0] min_in, sec_in;
	input [4:0] hr_in;
	
	output reg [7:0] hr_out, min_out, sec_out; // 8-bit BCD format for hr, min, sec
	
	always @(*) begin
		hr_out = (hr_in / 8'd10) * 8'd16 + (hr_in % 10);
		min_out = (min_in / 8'd10) * 8'd16 + (min_in % 10);
		sec_out = (sec_in / 8'd10) * 8'd16 + (sec_in % 10);
	end
	
endmodule 
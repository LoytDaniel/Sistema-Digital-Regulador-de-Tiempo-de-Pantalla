module Decod_BCD_to_Pixel (
    input [3:0] bcd,
    output reg [7:0] num_data [0:6]
);

always @(*) begin
    case (bcd)
        4'b0000: num_data = {8'h00, 8'h3E, 8'h51, 8'h49, 8'h45, 8'h3E, 8'h00};
        4'b0001: num_data = {8'h00, 8'h00, 8'h42, 8'h7F, 8'h40, 8'h00, 8'h00};
        4'b0010: num_data = {8'h00, 8'h42, 8'h61, 8'h51, 8'h49, 8'h46, 8'h00};
        4'b0011: num_data = {8'h00, 8'h21, 8'h41, 8'h45, 8'h4B, 8'h31, 8'h00};
        4'b0100: num_data = {8'h00, 8'h18, 8'h14, 8'h12, 8'h7F, 8'h10, 8'h00};
        4'b0101: num_data = {8'h00, 8'h27, 8'h45, 8'h45, 8'h45, 8'h39, 8'h00};
        4'b0110: num_data = {8'h00, 8'h3C, 8'h4A, 8'h49, 8'h49, 8'h30, 8'h00};
        4'b0111: num_data = {8'h00, 8'h01, 8'h71, 8'h09, 8'h05, 8'h03, 8'h00};
        4'b1000: num_data = {8'h00, 8'h36, 8'h49, 8'h49, 8'h49, 8'h36, 8'h00};
        4'b1001: num_data = {8'h00, 8'h06, 8'h49, 8'h49, 8'h29, 8'h1E, 8'h00};
        default: num_data = {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
    endcase
end
    
endmodule
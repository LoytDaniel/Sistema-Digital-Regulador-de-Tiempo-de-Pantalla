module Decod_rtc (
    input [3:0] bdc,
    output reg [6:0] num_data [0:7]
);

always @(bcd) begin
    case (bcd)
        4'b0000: num_data= {00, 3E, 51, 49, 45, 3E, 00};
        4'b0001: num_data= {00, 00, 42, 7F, 40, 00, 00};
        4'b0010: num_data= {00, 42, 61, 51, 49, 46, 00};
        4'b0011: num_data= {00, 21, 41, 45, 4B, 31, 00};
        4'b0100: num_data= {00, 18, 14, 12, 7F, 10, 00};
        4'b0101: num_data= {00, 27, 45, 45, 45, 39, 00};
        4'b0110: num_data= {00, 3C, 4A, 49, 49, 30, 00};
        4'b0111: num_data= {00, 01, 71, 09, 05, 03, 00};
        4'b1000: num_data= {00, 36, 49, 49, 49, 36, 00};
        4'b1001: num_data= {00, 06, 49, 49, 29, 1E, 00};
        default: num_data= {00, 00, 00, 00, 00, 00, 00}; //no hacer nada
    endcase
end
    
endmodule
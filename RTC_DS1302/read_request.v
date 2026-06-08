module read_request (
    input clk1, rstn,
    output reg read_tick
    );

reg [19:0] sec_counter; // Counter to generate a tick every second, assuming clk1 is 1 MHz

always @(posedge clk1) begin
    if(!rstn) begin
        sec_counter <= 0;
        read_tick <= 0;
    end
    else begin
        if(sec_counter == 999999) begin
            sec_counter <= 0;
            read_tick <= 1;
        end
        else begin
            sec_counter <= sec_counter + 1;
            read_tick <= 0;
        end
    end
end
    
endmodule
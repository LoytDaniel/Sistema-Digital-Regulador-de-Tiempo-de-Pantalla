module FSM_button (
    input clk, reset,
    input button_in,
    output reg button_out
);

localparam SCAN = 1'b0;
localparam DEBOUNCE= 1'b1;

reg state, next_state;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= SCAN;
    end else begin
        state <= next_state;
    end
end

reg  counter;

always @(*) begin
    if (reset) begin
        next_state = SCAN;
        button_out = 1'b0;
    end else begin
        case (state)
            SCAN: begin
                if (button_in) begin
                    next_state = DEBOUNCE;
                    button_out = 1'b0;
                end else begin
                    next_state = SCAN;
                    button_out = 1'b0;
                end
            end
            DEBOUNCE: begin
                button_out = 1'b1;
                if (counter== 1'b1)
                    next_state=SCAN;
                else 
                    next_state=DEBOUNCE;
                counter=counter+1;
            end
        endcase
    end
end

endmodule
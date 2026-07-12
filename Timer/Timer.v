module Timer #(
    parameter COUNT_MAX = 250000 )(

    input clk,
    input reset,
    input start, pause,
    input kids,
    input temp_enable,
    input [6:0] current_time [0:1],
    input [6:0] limit_time [0:1],

    output reg [6:0] left_time [0:1],
    output reg off_enable 
);

reg [10:0] start_time_minute, current_time_minute, timer_minute, limit_time_minute, left_time_saved;
reg subtract_enable;
wire pause_cleaned, start_cleaned;

// ---------------------------------------------------------------------------
// Divisor de frecuencia → clk_10ms
// ---------------------------------------------------------------------------
reg [$clog2(COUNT_MAX)-1:0] clk_counter;
reg clk_10ms;

always @(posedge clk) begin
    if (clk_counter == COUNT_MAX - 1) begin
        clk_10ms <= ~clk_10ms;
        clk_counter <= 'b0;
    end else begin
        clk_counter <= clk_counter + 1;
    end
end
//---------------------------------------------------------------------------

always @(*)begin
    FSM_button start_fsm (
        .clk(clk_10ms),
        .reset(reset),
        .button_in(start),
        .button_out(start_cleaned)
    );

    FSM_button pause_fsm (
        .clk(clk_10ms),
        .reset(reset),
        .button_in(pause),
        .button_out(pause_cleaned)
    );
end

// Intancia para detener y continuar el temporizador
always @(posedge start_cleaned) begin
    if (kids) begin
        if (~subtract_enable) begin
            start_time_minute=minutes(current_time[1], current_time[0]);
            limit_time_minute=minutes(limit_time[1], limit_time[0]);
            subtract_enable <= 1'b1;
        end
    end 
end

always @(posedge pause_cleaned) begin
    if (kids) begin
        subtract_enable <= 1'b0;
        left_time_saved=timer_minute;
        off_enable <= 1'b1;
    end
end


always @(posedge clk_10ms) begin

    if (reset) begin //usarlo cuando paso un dia y que vuelva todo a 0

        left_time[0] <= 7'd0;
        left_time[1] <= 7'd0;
        off_enable <= 1'b0;
        subtract_enable <= 1'b0;
        timer_minute <= 11'd0;
        left_time_saved <= 11'd0;

    end else if (kids || temp_enable) begin

        if (subtract_enable) begin

            current_time_minute=minutes(current_time[1],current_time[0]);
            timer_minute=current_time_minute-start_time_minute+left_time_saved;

            if (timer_minute >= limit_time_minute) begin
                left_time[0] <= 7'd0;
                left_time[1] <= 7'd0;
                subtract_enable <= 1'b0;
                off_enable <= 1'b1;

            end else begin
                left_time[0] <= (limit_time_minute - timer_minute) % 60;
                left_time[1] <= (limit_time_minute - timer_minute) / 60;
                off_enable <= 1'b0;
            end

        end
        
    end else begin
        left_time_saved=timer_minute;
        subtract_enable <= 1'b0;
        off_enable <= 1'b1;
    end
end


function [10:0] minutes;
    input [6:0] hour, minute;
    begin
        minutes = minute[3:0] + minute[6:4]*10 + hour[3:0]*60 + hour[6:4]*600;
    end
    
endfunction

endmodule
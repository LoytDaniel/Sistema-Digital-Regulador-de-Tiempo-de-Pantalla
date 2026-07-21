module Timer #(
    parameter COUNT_MAX = 250000 )(

    input clk,
    input reset,
    input start, pause,
    input kids,
    input temp_enable,
    input [7:0] current_time_H, current_time_M, current_time_S,
    input [7:0] limit_time_H, limit_time_M,

    output [7:0] left_time_BCD_H, left_time_BCD_M,
    output reg off_enable, 
    output timer_enable
);

reg [16:0] start_time_second, current_time_second, timer_second, limit_time_second, left_time_saved;
reg [5:0] left_time [0:1];
reg subtract_enable;
reg [7:0] a;
wire pause_cleaned, start_cleaned;

assign timer_enable=subtract_enable;

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

// Instancia para detener y continuar el temporizador

reg start_cleaned_d, pause_cleaned_d;

always @(posedge clk_10ms) begin
    start_cleaned_d <= start_cleaned;
    pause_cleaned_d <= pause_cleaned;
end

wire start_edge = start_cleaned & ~start_cleaned_d;
wire pause_edge = pause_cleaned & ~pause_cleaned_d;

//Activar la señal de reinicio de dia
wire reset_day;
assign reset_day = ((current_time_H == 8'd0) && (current_time_M == 8'd0)) ? 1'b1 : 1'b0;


always @(posedge clk_10ms) begin

    limit_time_second <= seconds(limit_time_H, limit_time_M, 8'd0)+17'd59;
    if (reset_day || reset) begin //usarlo cuando paso un dia y que vuelva todo a 0

        left_time[0] <= ((limit_time_second) % 3600) /60; //minutos
        left_time[1] <= (limit_time_second) / 3600; //horas
        off_enable <= 1'b0;
        subtract_enable <= 1'b0;
        timer_second <= 11'd0;
        left_time_saved <= 11'd0;

    
    end else if (kids && temp_enable) begin

        if (start_edge && ~subtract_enable) begin
        start_time_second <= seconds(current_time_H, current_time_M, current_time_S);
        subtract_enable <= 1'b1;
        end

        if (pause_edge) begin
            subtract_enable  <= 1'b0;
            left_time_saved  <= timer_second;
            off_enable       <= 1'b1;
        end
        if (subtract_enable) begin

            current_time_second= (seconds(current_time_H,current_time_M, current_time_S));
            timer_second=(current_time_second-start_time_second+left_time_saved);

            if (timer_second >= (limit_time_second-17'd0)) begin
                left_time[0] <= 8'd0;
                left_time[1] <= 8'd0;
                timer_second=limit_time_second;
                subtract_enable <= 1'b0;
                off_enable <= 1'b1;

            end else begin
                left_time[0] <= ((limit_time_second - timer_second) % 3600) /60; //minutos
                left_time[1] <= (limit_time_second - timer_second) / 3600; //horas
                off_enable <= 1'b0;
            end

        end
        
    end else begin

        if (~temp_enable) begin
            left_time[0] <= 8'd0;
            left_time[1] <= 8'd0;
        end else begin
            left_time_saved <= timer_second;
            left_time[0] <= ((limit_time_second - left_time_saved) % 3600) /60; //minutos
            left_time[1] <= (limit_time_second - left_time_saved) / 3600; //horas
        end
        subtract_enable <= 1'b0;
        off_enable <= 1'b1;
    end
end


function [16:0] seconds;
    input [7:0] hour, minute, second;
    begin
        seconds = second[3:0] + second[7:4]*10 + minute[3:0]*60 + minute[7:4]*600 + hour[3:0]*3600 + hour[7:4]*36000;
    end
    
endfunction

 Bin_to_BCD B1(
        .hr_in(left_time[1]),
        .min_in(left_time[0]),
        .hr_out(left_time_BCD_H),
        .min_out(left_time_BCD_M),
    );

endmodule
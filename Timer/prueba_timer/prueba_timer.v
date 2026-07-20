module prueba_timer (
    input clk, rstn, wr_btn, set_btn,
	input [5:0] ext_input,
	input b_start, b_pause, kids, temp_enable,
	output CE, SCLK,
    inout IO,
    output off,
    output di, // Data/Instruction (0=cmd, 1=dato)
    output rw, // Read/Write (siempre 0=write)
    output enable, // Pulso de habilitación (= clk_16ms)
    output cs1, // Chip Select lado izquierdo
    output cs2, // Chip Select lado derecho
    output [7:0] data// Bus de datos 8 bits
);

wire [7:0] hr_out, min_out, sec_out;
wire nreset, noff, nb_start, nb_pause;
wire [7:0] left_time_BCD [0:1];
assign nreset = ~rstn;
assign nb_start = ~b_start;
assign nb_pause = ~b_pause;

DS1302_Top_prueba ds(
    .clk(clk),
    .rstn(rstn),
    .wr_btn(wr_btn),
    .set_btn(set_btn),
    .ext_input(ext_input),
    .CE(CE),
    .SCLK(SCLK),
    .IO(IO),
    .hr_out(hr_out),
    .min_out(min_out)
);

Timer pt(
    .clk(clk),
    .reset(nreset),
    .start(nb_start),
    .pause(nb_pause),
    .kids(kids),
    .temp_enable(temp_enable),
    .current_time_H(hr_out),
    .current_time_M(min_out),
    .limit_time_H(8'd0),
    .limit_time_M(8'd3), // Set the limit time to 5 minutes
    .left_time_BCD_H(left_time_BCD[1]),
    .left_time_BCD_M(left_time_BCD[0]),
    .off_enable(noff)
);

LCD12864_controller_p3 inst(
    .clk(clk),
    .reset(rstn),
    .di(di), // Data/Instruction (0=cmd, 1=dato)
    .rw(rw), // Read/Write (siempre 0=write)
    .enable(enable), // Pulso de habilitación (= clk_16ms)
    .cs1(cs1), // Chip Select lado izquierdo
    .cs2(cs2), // Chip Select lado derecho
    .data(data),// Bus de datos 8 bits
    //Variables para el cambio de pantalla
    .kids(kids),
    .left_time_H(left_time_BCD[1]),
    .left_time_M(left_time_BCD[0])
);

assign off = ~noff;

endmodule
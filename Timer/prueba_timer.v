module prueba_timer (
    input clk, rstn, wr_btn, set_btn,
	input [5:0] ext_input,
	input b_start, b_pause, kids, temp_enable,
	output [6:0] seg,
    output [5:0] bitON,
	output CE, SCLK,
    inout IO,
    output off
);

wire [7:0] hr_out, min_out, sec_out;
wire nreset;
wire [7:0] left_time_BCD [0:1];
wire [5:0] nbitON;
wire [6:0] nseg;
assign nreset = ~rstn;

DS1302_Top_prueba(
    .clk(clk),
    .rstn(rstn),
    .wr_btn(wr_btn),
    .set_btn(set_btn),
    .ext_input(ext_input),
    .CE(CE),
    .SCLK(SCLK),
    .IO(IO),
    .hr_out(hr_out),
    .min_out(min_out),
    .sec_out(sec_out),
);

Timer pt(
    .clk(clk),
    .reset(nreset),
    .start(b_start),
    .pause(b_pause),
    .kids(kids),
    .temp_enable(temp_enable),
    .current_time_H(hr_out),
    .current_time_M(min_out),
    .limit_time_H(8'd0),
    .limit_time_M(8'd5), // Set the limit time to 5 minutes
    .left_time_BCD_H(left_time_BCD[1]),
    .left_time_BCD_M(left_time_BCD[0]),
    .off_enable(off)
);


Display_7_seg display(.clk(clk),
					    .rstn(rstn),
                        .hr(left_time_BCD[1]), 
                        .min(left_time_BCD[0]), 
                        .sec(8'd0), 
                        .seg(nseg), 
                        .bitON(nbitON)
                    );    


assign bitON = ~nbitON;
assign seg = ~nseg;

endmodule
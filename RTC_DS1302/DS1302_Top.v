module DS1302_Top (
	input clk, rstn, wr_btn, set_btn,
	input [5:0] ext_input,
	
	output [6:0] seg,
    output [5:0] bitON,
	output CE, SCLK,
    inout IO,
	output hr_en, min_en, sec_en
);
	
	wire clk1, rd_tick, set_stable;
	wire [4:0] hr;
	wire [5:0] min, sec;
	wire [7:0] hr_bcd, min_bcd, sec_bcd;
	wire [63:0] time_data_out;
    wire [7:0] hr_out, min_out, sec_out;

    //logica negada
    wire [5:0] next_input;
    wire nwr_btn, nset_btn;
	wire [5:0] nbitON;
	wire [6:0] nseg;
    assign nwr_btn = ~wr_btn;
    assign nset_btn = ~set_btn;
    assign next_input = ~ext_input;

	Debounce db(.clk(clk), 
				.rstn(rstn), 
				.set(nset_btn),
				.set_stable(set_stable)
				);

    Time_setting time_set(.clk(clk), 
                          .rstn(rstn), 
                          .ext_input(next_input), 
                          .set(set_stable), 
                          .hr(hr), 
                          .min(min), 
                          .sec(sec),
						  .hr_en(hr_en),
						  .min_en(min_en),
						  .sec_en(sec_en)
                            );
	
	CLK_div cl(.clk_in(clk), .clk_out(clk1));
	
	Bin_to_BCD bcd (.hr_in(hr), 
					.min_in(min), 
					.sec_in(sec), 
					.hr_out(hr_bcd), 
					.min_out(min_bcd), 
    				.sec_out(sec_bcd)
        			);

    read_request rd(.clk1(clk1), 
                    .rstn(rstn), 
                    .read_tick(rd_tick)
                   );
	
	DS1302_controller Controller (.clk1(clk1), 
								  .rstn(rstn), 
					   			  .rd_tick(rd_tick), 
					   			  .wr_btn(nwr_btn), 
								  .hr(hr_bcd), 
						 		  .min(min_bcd), 
								  .sec(sec_bcd), 
					 			  .time_out(time_data_out), 
								  .CE(CE), 
								  .SCLK(SCLK), 
								  .IO(IO)
								);
	
	// Extract hour, minute, second from the 64-bit register read from RTC in burst mode
	assign hr_out = {2'b00, time_data_out[21:16]}; // Bit 7 of hour register is to set 12/24 hour mode, bit 6 always read 0
	assign min_out = {1'b0, time_data_out[14:8]}; // Bit 7 of minute register does not affect the minute reading
	assign sec_out = {1'b0, time_data_out[6:0]}; // Bit 7 of second register is the Clock Halt (CH) flag
	
    Display_7_seg display(.clk(clk),
							.rstn(rstn),
                            .hr(hr_out), 
                            .min(min_out), 
                            .sec(sec_out), 
                            .seg(nseg), 
                            .bitON(nbitON)
                        );

	assign bitON = ~nbitON;
	assign seg = ~nseg;

endmodule
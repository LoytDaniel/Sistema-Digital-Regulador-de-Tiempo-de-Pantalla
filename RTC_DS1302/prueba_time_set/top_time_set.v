module top_time_set (
    input clk, rstn, set,
    input [5:0] ext_input,
    output [6:0] seg,
    output [5:0] bitON,
    output hr_en, min_en, sec_en
);

wire set_stable;
wire [4:0] hr;
wire [5:0] min, sec;
wire [7:0] hr_bcd, min_bcd, sec_bcd; 

wire [7:0] nseg;
wire [5:0] nbitON;
wire nset;
wire [5:0] next_input;

assign nset = ~set;
assign next_input = ~ext_input;

debounce db(
    .clk(clk),
    .rstn(rstn),
    .set(nset),
    .set_stable(set_stable)
);

Time_setting time_set(
    .clk(clk), 
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

Bin_to_BCD bcd(
    .hr_in(hr),
    .min_in(min),
    .sec_in(sec),
    .hr_out(hr_bcd),
    .min_out(min_bcd),
    .sec_out(sec_bcd)
);

Display_7_seg display(
    .clk(clk),
    .rstn(rstn),
    .hr(hr_bcd),
    .min(min_bcd),
    .sec(sec_bcd),
    .seg(nseg),
    .bitON(nbitON)
);

assign seg = ~nseg;
assign bitON = ~nbitON;

endmodule
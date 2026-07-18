module prueba_lcd_din #(
    parameter DATA_BITS = 8
)(
    input clk, rstn, wr_btn, set_btn, adult,
    input [5:0] ext_input,
    output CE, SCLK,
    inout IO,
    output di, // Data/Instruction (0=cmd, 1=dato)
    output rw, // Read/Write (siempre 0=write)
    output enable, // Pulso de habilitación (= clk_16ms)
    output cs1, // Chip Select lado izquierdo
    output cs2, // Chip Select lado derecho
    output [DATA_BITS-1:0] data// Bus de datos 8 bits
);

wire [7:0] hr_out, min_out;

DS1302_Top_p DS1302_Top_p_inst (
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

LCD12864_controller_prueba1 inst (
    .clk(clk), 
    .reset(rstn),
    .di(di),
    .rw(rw),
    .enable(enable),
    .cs1(cs1),
    .cs2(cs2),
    .data(data),
    .adult(adult),
    .current_hr(hr_out),
    .current_min(min_out)
);

endmodule
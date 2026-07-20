module screens_change_p (
    input reset, clk,
    input exit, correct_password,
    input [3:0] key,
    output di, // Data/Instruction (0=cmd, 1=dato)
    output rw, // Read/Write (siempre 0=write)
    output enable, // Pulso de habilitación (= clk_16ms)
    output cs1, // Chip Select lado izquierdo
    output cs2, // Chip Select lado derecho
    output [7:0] data// Bus de datos 8 bits
);

wire kids, password, menu, adult, setting;
wire [1:0] options;

wire nreset, nexit, ncorrect_password;
assign nreset = ~reset;
assign nexit = ~exit;
assign ncorrect_password = ~correct_password;

fsm_screen FS( 
    .clk(clk),
    .reset(nreset),
    .exit(nexit),
    .correct_password(ncorrect_password),
    .sel(options),

    .kids(kids),
    .password(password),
    .menu(menu),
    .adult(adult),
    .setting(setting)
);

select_menu sel(
    .menu(menu),
    .key_value(key),
    .options(options)
);

LCD12864_controller_p4 inst(
    .clk(clk),
    .reset(reset),
    .di(di), // Data/Instruction (0=cmd, 1=dato)
    .rw(rw), // Read/Write (siempre 0=write)
    .enable(enable), // Pulso de habilitación (= clk_16ms)
    .cs1(cs1), // Chip Select lado izquierdo
    .cs2(cs2), // Chip Select lado derecho
    .data(data),// Bus de datos 8 bits
    //Variables para el cambio de pantalla
    .kids(kids),
    .password(password), 
    .menu(menu), 
    .adult(adult), 
    .setting(setting)
);
    
endmodule
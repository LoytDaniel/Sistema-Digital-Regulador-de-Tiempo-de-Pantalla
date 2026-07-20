module screens_change_p (
    input reset, clk,
    input exit, correct_password,
    input [1:0] sel,

);

wire kids, password, menu, adult, setting;



fsm_screen FS( 
    .clk(clk),
    .reset(reset),
    .exit(exit),
    .correct_password(correct_password),
    .sel(sel),

    .kids(kids),
    .password(password),
    .menu(menu),
    .adult(adult),
    .setting(setting)
);

LCD12864_controller_p4 inst(
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
    .password(password), 
    .menu(menu), 
    .adult(adult), 
    .setting(setting)
);


);
    
endmodule
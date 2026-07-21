// =============================================================================
// La pantalla se divide en dos mitades de 64x64 píxeles:
//   - CS1 activo: columnas 0–63  (lado izquierdo)
//   - CS2 activo: columnas 64–127 (lado derecho)
//
// La RAM gráfica se organiza en 8 páginas (X=0..7) × 64 columnas por chip.
// Cada byte escrito representa 8 píxeles en dirección vertical (DB0=arriba).
module LCD12864_controller #(
    parameter NUM_COMMANDS = 4,
    parameter NUM_COLS = 64,
    parameter NUM_PAGES = 8,
    parameter DATA_BITS = 8,
    parameter COUNT_MAX = 500,
    parameter NUM_DATA_ALL = 1024, // Datos gráficos: 2 chips × 8 páginas × 64 columnas = 1024 bytes
    parameter CLOCK_FPGA = 50_000_000 // Frecuencia del reloj de la FPGA (Hz)
)(
    input clk, reset,
    output reg di, // Data/Instruction (0=cmd, 1=dato)
    output reg rw, // Read/Write (siempre 0=write)
    output enable, // Pulso de habilitación (= clk_16ms)
    output reg cs1, // Chip Select lado izquierdo
    output reg cs2, // Chip Select lado derecho
    output reg [DATA_BITS-1:0] data,// Bus de datos 8 bits
    //Variables para el cambio de pantalla
    input kids, password, menu, adult, setting,
    input [7:0] left_time_H, left_time_M,
    input [7:0] current_hr, current_min,
    input [2:0] num_ingresados,
    input pass_incorrecta,
    input [7:0] tiempo_hr, tiempo_min,
    input [7:0] inicio_hr, inicio_min,
    input [7:0] final_hr, final_min,
    input [1:0] posicion_fila, // 0: fila 1 (tiempo) 1: fila 2 (inicio) 2: fila 3 (final) 
    input [1:0] posicion_columna // 0: columna 1 (decena hora) 1: columna 2 (unidades hora) 2: columna 3 (decena minuto) 3: columna 4 (unidades minuto)
);

//memorias para cada pantalla
reg [7:0] kids_mem [0:1023];
reg [7:0] adult_mem [0:1023];
reg [7:0] menu_mem [0:1023];
reg [7:0] password_mem [0:1023];
reg [7:0] setting_mem [0:1023];

reg [7:0] pixel_asterisco [0:6];
reg [7:0] pixel_guion [0:6];

//Contador para el parpadeo del cursor en la pantalla de configuración
reg [24:0] blink_cnt;
reg cursor_visible;

always @(posedge clk) begin
    if (!reset) begin
        blink_cnt <= 0;
        cursor_visible <= 0;
    end else begin
        if (blink_cnt == CLOCK_FPGA/2) begin  // cada 500ms
            blink_cnt <= 0;
            cursor_visible <= ~cursor_visible;
        end else begin
            blink_cnt <= blink_cnt + 1;
        end
    end
end

// Comandos KS0108
localparam DISPLAY_ON = 8'h3F;  // 0011 1111  – Display ON
localparam DISPLAY_OFF = 8'h3E;  // 0011 1110  – Display OFF
localparam SET_START_L0 = 8'hC0;  // 1100 0000  – Start line = 0
localparam SET_PAGE_0 = 8'hB8;  // 1011 1000  – Página (X) = 0
localparam SET_Y_0 = 8'h40;  // 0100 0000  – Y address = 0

//estados
localparam IDLE = 3'd0;
localparam CONFIG_CS1 = 3'd1;  // Enviar 4 comandos de init al chip 1
localparam SET_PG_CS1 = 3'd2;   // Enviar Set Page al chip 1 antes de cada página
localparam WR_DATA_CS1 = 3'd3;   // Escribir 64 bytes de datos en chip 1
localparam CONFIG_CS2 = 3'd4;  // Enviar 4 comandos de init al chip 2
localparam SET_PG_CS2 = 3'd5;   // Enviar Set Page al chip 2 antes de cada página
localparam WR_DATA_CS2 = 3'd6;   // Escribir 64 bytes de datos en chip 2
localparam NEXT_PG = 3'd7; // Avanzar página chip 1

reg [3:0] fsm_state;
reg [3:0] next_state;

// Divisor de frecuencia → clk_10 microsegundos frecuencia de 100kHz
reg [$clog2(COUNT_MAX)-1:0] clk_counter;
reg clk_10;

always @(posedge clk) begin
    if (clk_counter == COUNT_MAX - 1) begin
        clk_10 <= ~clk_10;
        clk_counter <= 'b0;
    end else begin
        clk_counter <= clk_counter + 1;
    end
end

assign enable = clk_10;

// Contadores
reg [$clog2(NUM_COMMANDS):0] command_counter; // Índice sobre config_mem
reg [$clog2(NUM_COLS):0] data_counter;    // Columna dentro de la página
reg [$clog2(NUM_PAGES):0] page_counter;    // Página actual (0..7)

// Memorias
// Disposición en los archivos de texto (hex):
//   [0..511]   → chip 1: página 0 cols 0-63, página 1 cols 0-63 … página 7
//   [512..1023]→ chip 2: ídem
reg [DATA_BITS-1:0] config_mem [0:NUM_COMMANDS-1];
reg [DATA_BITS-1:0] graphic_mem [0:NUM_DATA_ALL-1]; // Memoria gráfica de 1024 bytes

initial begin
    fsm_state <= IDLE;
    command_counter <= 'b0;
    data_counter <= 'b0;
    page_counter <= 'b0;
    di <= 1'b0;
    rw <= 1'b0; // Siempre escritura
    cs1 <= 1'b0;
    cs2 <= 1'b0;
    data <= 8'b0;
    clk_10 <= 1'b0;
    clk_counter <= 'b0;
    // Cargar memorias gráficas desde archivos de texto
    $readmemh("../LCD_128X64/Screens/KIDS_MODE.txt",kids_mem);
    $readmemh("../LCD_128X64/Screens/ADULT_MODE.txt",adult_mem);
    $readmemh("../LCD_128X64/Screens/MAIN_MENU.txt",menu_mem);
    $readmemh("../LCD_128X64/Screens/PASSWORD.txt",password_mem);
    $readmemh("../LCD_128X64/Screens/SETTINGS.txt",setting_mem);
    pixel_asterisco[0] = 8'h00;
    pixel_asterisco[1] = 8'h14;
    pixel_asterisco[2] = 8'h08;
    pixel_asterisco[3] = 8'h3E;
    pixel_asterisco[4] = 8'h08;
    pixel_asterisco[5] = 8'h14;
    pixel_asterisco[6] = 8'h00;
    pixel_guion[0] = 8'h00;
    pixel_guion[1] = 8'h40;
    pixel_guion[2] = 8'h40;
    pixel_guion[3] = 8'h40;
    pixel_guion[4] = 8'h40;
    pixel_guion[5] = 8'h40;
    pixel_guion[6] = 8'h00;
    // Secuencia de inicialización KS0108 (igual para CS1 y CS2)
    config_mem[0] <= SET_START_L0;  // Línea de inicio = 0
    config_mem[1] <= SET_PAGE_0;    // Página 0 (X address)
    config_mem[2] <= SET_Y_0;       // Y address = 0
    config_mem[3] <= DISPLAY_ON;    // Display ON
end

wire [55:0] left_time_hr_pix_dec, left_time_hr_pix_uni, left_time_min_pix_dec, left_time_min_pix_uni;
wire [55:0] current_hr_pix_dec, current_hr_pix_uni, current_min_pix_dec, current_min_pix_uni;
wire [55:0] tiempo_hr_pix_dec, tiempo_hr_pix_uni, tiempo_min_pix_dec, tiempo_min_pix_uni;
wire [55:0] inicio_hr_pix_dec, inicio_hr_pix_uni, inicio_min_pix_dec, inicio_min_pix_uni;
wire [55:0] final_hr_pix_dec, final_hr_pix_uni, final_min_pix_dec, final_min_pix_uni;

screen_builder_pixel screen_builder_inst(
    .current_hr(current_hr), .current_min(current_min), 
    .left_time_H(left_time_H), .left_time_M(left_time_M),
    .tiempo_hr(tiempo_hr), .tiempo_min(tiempo_min),
    .inicio_hr(inicio_hr), .inicio_min(inicio_min),
    .final_hr(final_hr), .final_min(final_min),
    .current_hr_pixel_dec(current_hr_pix_dec), .current_hr_pixel_uni(current_hr_pix_uni),
    .current_min_pixel_dec(current_min_pix_dec), .current_min_pixel_uni(current_min_pix_uni),
    .left_time_hr_pixel_dec(left_time_hr_pix_dec), .left_time_hr_pixel_uni(left_time_hr_pix_uni),
    .left_time_min_pixel_dec(left_time_min_pix_dec), .left_time_min_pixel_uni(left_time_min_pix_uni),
    .tiempo_hr_pixel_dec(tiempo_hr_pix_dec), .tiempo_hr_pixel_uni(tiempo_hr_pix_uni),
    .tiempo_min_pixel_dec(tiempo_min_pix_dec), .tiempo_min_pixel_uni(tiempo_min_pix_uni),
    .inicio_hr_pixel_dec(inicio_hr_pix_dec), .inicio_hr_pixel_uni(inicio_hr_pix_uni),
    .inicio_min_pixel_dec(inicio_min_pix_dec), .inicio_min_pixel_uni(inicio_min_pix_uni),
    .final_hr_pixel_dec(final_hr_pix_dec), .final_hr_pixel_uni(final_hr_pix_uni),
    .final_min_pixel_dec(final_min_pix_dec), .final_min_pixel_uni(final_min_pix_uni)
);

reg [7:0] left_time_hr_pixel_dec [0:6];
reg [7:0] left_time_hr_pixel_uni [0:6];
reg [7:0] left_time_min_pixel_dec [0:6];
reg [7:0] left_time_min_pixel_uni [0:6];
reg [7:0] current_hr_pixel_dec [0:6];
reg [7:0] current_hr_pixel_uni [0:6];
reg [7:0] current_min_pixel_dec [0:6];
reg [7:0] current_min_pixel_uni [0:6];
reg [7:0] tiempo_hr_pixel_dec [0:6];
reg [7:0] tiempo_hr_pixel_uni [0:6];
reg [7:0] tiempo_min_pixel_dec [0:6];
reg [7:0] tiempo_min_pixel_uni [0:6];
reg [7:0] inicio_hr_pixel_dec [0:6];
reg [7:0] inicio_hr_pixel_uni [0:6];
reg [7:0] inicio_min_pixel_dec [0:6];
reg [7:0] inicio_min_pixel_uni [0:6];
reg [7:0] final_hr_pixel_dec [0:6];
reg [7:0] final_hr_pixel_uni [0:6];
reg [7:0] final_min_pixel_dec [0:6];
reg [7:0] final_min_pixel_uni [0:6];

integer i, j;

always @(*) begin
    for(i = 0; i < 7; i = i + 1) begin
        left_time_hr_pixel_dec[i] = left_time_hr_pix_dec[i*8 +: 8];
        left_time_hr_pixel_uni[i] = left_time_hr_pix_uni[i*8 +: 8];
        left_time_min_pixel_dec[i] = left_time_min_pix_dec[i*8 +: 8];
        left_time_min_pixel_uni[i] = left_time_min_pix_uni[i*8 +: 8];
        current_hr_pixel_dec[i] = current_hr_pix_dec[i*8 +: 8];
        current_hr_pixel_uni[i] = current_hr_pix_uni[i*8 +: 8];
        current_min_pixel_dec[i] = current_min_pix_dec[i*8 +: 8];
        current_min_pixel_uni[i] = current_min_pix_uni[i*8 +: 8];
        tiempo_hr_pixel_dec[i] = tiempo_hr_pix_dec[i*8 +: 8];
        tiempo_hr_pixel_uni[i] = tiempo_hr_pix_uni[i*8 +: 8];
        tiempo_min_pixel_dec[i] = tiempo_min_pix_dec[i*8 +: 8];
        tiempo_min_pixel_uni[i] = tiempo_min_pix_uni[i*8 +: 8];
        inicio_hr_pixel_dec[i] = inicio_hr_pix_dec[i*8 +: 8];
        inicio_hr_pixel_uni[i] = inicio_hr_pix_uni[i*8 +: 8];
        inicio_min_pixel_dec[i] = inicio_min_pix_dec[i*8 +: 8];
        inicio_min_pixel_uni[i] = inicio_min_pix_uni[i*8 +: 8];
        final_hr_pixel_dec[i] = final_hr_pix_dec[i*8 +: 8];
        final_hr_pixel_uni[i] = final_hr_pix_uni[i*8 +: 8];
        final_min_pixel_dec[i] = final_min_pix_dec[i*8 +: 8];
        final_min_pixel_uni[i] = final_min_pix_uni[i*8 +: 8];
    end
end

//Asignación de las matrices
always @(*) begin
    for (i = 0; i < NUM_DATA_ALL; i = i + 1) begin //Carga el arreglo de memoria gráfica con la pantalla correspondiente
        if (kids) graphic_mem[i] = kids_mem[i];
        else if (password) graphic_mem[i] = password_mem[i];
        else if (menu) graphic_mem[i] = menu_mem[i];
        else if (adult) graphic_mem[i] = adult_mem[i];
        else if (setting) graphic_mem[i] = setting_mem[i];
    end

//Cambiar las posiciones dinamicas
    if (kids) begin
        for (j = 0; j < 7; j = j + 1) begin
            graphic_mem[430+j]=left_time_hr_pixel_dec[6-j];
            graphic_mem[437+j]=left_time_hr_pixel_uni[6-j];
            graphic_mem[448+j]=left_time_min_pixel_dec[6-j];
            graphic_mem[455+j]=left_time_min_pixel_uni[6-j];
        end
    end
    else if (password) begin
        if (pass_incorrecta) begin
            for (j = 0; j < 7; j = j + 1) begin  //Cargar los guiones si la contraseña es incorrecta
            graphic_mem[307+j] = pixel_guion[6-j];
            graphic_mem[314+j] = pixel_guion[6-j];
            graphic_mem[321+j] = pixel_guion[6-j];
            graphic_mem[328+j] = pixel_guion[6-j];
            end
        end else begin
            for (j = 0; j < 128; j = j + 1) begin  //Quitar la linea de contraseña incorrecta
                graphic_mem[384+j]=password_mem[128+j];
            end
        end 
        for (j = 0; j < 7; j = j + 1) begin  //Cargar los asteriscos o guiones dependiendo del número de dígitos ingresados
            graphic_mem[307+j] = (num_ingresados >= 1) ? pixel_asterisco[6-j] : pixel_guion[6-j];
            graphic_mem[314+j] = (num_ingresados >= 2) ? pixel_asterisco[6-j] : pixel_guion[6-j];
            graphic_mem[321+j] = (num_ingresados >= 3) ? pixel_asterisco[6-j] : pixel_guion[6-j];
            graphic_mem[328+j] = (num_ingresados >= 4) ? pixel_asterisco[6-j] : pixel_guion[6-j];
        end 
    end
    else if (adult) begin
        for (j = 0; j < 7; j = j + 1) begin
            graphic_mem[430+j]=current_hr_pixel_dec[6-j];
            graphic_mem[437+j]=current_hr_pixel_uni[6-j];
            graphic_mem[448+j]=current_min_pixel_dec[6-j];
            graphic_mem[455+j]=current_min_pixel_uni[6-j];
        end
    end
    else if (setting) begin
        for (j = 0; j < 7; j = j + 1) begin
            graphic_mem[309+j]=tiempo_hr_pixel_dec[6-j];
            graphic_mem[316+j]=tiempo_hr_pixel_uni[6-j];
            graphic_mem[327+j]=tiempo_min_pixel_dec[6-j];
            graphic_mem[334+j]=tiempo_min_pixel_uni[6-j];
            graphic_mem[444+j]=inicio_hr_pixel_dec[6-j];
            graphic_mem[451+j]=inicio_hr_pixel_uni[6-j];
            graphic_mem[462+j]=inicio_min_pixel_dec[6-j];
            graphic_mem[469+j]=inicio_min_pixel_uni[6-j];
            graphic_mem[558+j]=final_hr_pixel_dec[6-j];
            graphic_mem[565+j]=final_hr_pixel_uni[6-j];
            graphic_mem[576+j]=final_min_pixel_dec[6-j];
            graphic_mem[583+j]=final_min_pixel_uni[6-j];
        end
        if(!cursor_visible) begin
            for (j = 0; j < 7; j = j + 1) begin
                if(posicion_fila == 2'b00) begin //Fila 1 (tiempo)
                    if(posicion_columna == 2'b00) graphic_mem[309+j]=pixel_guion[6-j];
                    else if(posicion_columna == 2'b01) graphic_mem[316+j]=pixel_guion[6-j];
                    else if(posicion_columna == 2'b10) graphic_mem[327+j]=pixel_guion[6-j];
                    else if(posicion_columna == 2'b11) graphic_mem[334+j]=pixel_guion[6-j];
                end
                else if(posicion_fila == 2'b01) begin //Fila 2 (inicio)
                    if(posicion_columna == 2'b00) graphic_mem[444+j]=pixel_guion[6-j];
                    else if(posicion_columna == 2'b01) graphic_mem[451+j]=pixel_guion[6-j];
                    else if(posicion_columna == 2'b10) graphic_mem[462+j]=pixel_guion[6-j];
                    else if(posicion_columna == 2'b11) graphic_mem[469+j]=pixel_guion[6-j];
                end
                else if(posicion_fila == 2'b10) begin //Fila 3 (final)
                    if(posicion_columna == 2'b00) graphic_mem[558+j]=pixel_guion[6-j];
                    else if(posicion_columna == 2'b01) graphic_mem[565+j]=pixel_guion[6-j];
                    else if(posicion_columna == 2'b10) graphic_mem[576+j]=pixel_guion[6-j];
                    else if(posicion_columna == 2'b11) graphic_mem[583+j]=pixel_guion[6-j];
                end
            end
        end 
    end 
end

// Registro de estado (síncrono con clk_10)
always @(posedge clk_10) begin
    if (!reset)
        fsm_state <= IDLE;
    else
        fsm_state <= next_state;
end

// Lógica de próximo estado (combinacional)
always @(*) begin
    case (fsm_state)

        IDLE:
            next_state = CONFIG_CS1;

        //Chip 1: inicialización
        CONFIG_CS1:
            next_state = (command_counter == NUM_COMMANDS) ? SET_PG_CS1 : CONFIG_CS1;

        //Chip 1: enviar Set Page antes de escribir
        SET_PG_CS1:
            next_state = WR_DATA_CS1;

        //Chip 1: escribir 64 columnas de la página actual
        WR_DATA_CS1:
            next_state = (data_counter == NUM_COLS) ? CONFIG_CS2 : WR_DATA_CS1;

        //Chip 2: inicialización
        CONFIG_CS2:
            next_state = (command_counter == NUM_COMMANDS) ? SET_PG_CS2 : CONFIG_CS2;

        //Chip 2: enviar Set Page antes de escribir
        SET_PG_CS2:
            next_state = WR_DATA_CS2;

        //Chip 2: escribir 64 columnas de la página actual
        WR_DATA_CS2:
            next_state = (data_counter == NUM_COLS) ? NEXT_PG : WR_DATA_CS2;

        NEXT_PG:
            next_state = (page_counter == NUM_PAGES) ? IDLE : CONFIG_CS1; 

        default:
            next_state = IDLE;

    endcase
end

// Lógica de salida y actualización de contadores (síncrono con clk_10)
always @(posedge clk_10) begin
    if (!reset) begin
        command_counter <= 'b0;
        data_counter <= 'b0;
        page_counter <= 'b0;
        di <= 1'b0;
        cs1 <= 1'b1;
        cs2 <= 1'b1;
        data <= 'b0;
    end else begin
        case (next_state)
            IDLE: begin
                command_counter <= 'b0;
                data_counter <= 'b0;
                page_counter <= 'b0;
                di <= 1'b0;
                cs1 <= 1'b0;
                cs2 <= 1'b0;
                data <= 'b0;
            end

            //CHIP 1
            CONFIG_CS1: begin
                cs1 <= 1'b1;
                cs2 <= 1'b0;
                di <= 1'b0;  // Instrucción
                data <= config_mem[command_counter];
                command_counter <= command_counter + 1;
            end

            SET_PG_CS1: begin
                // Resetear contadores al entrar a nueva página
                command_counter <= 'b0;
                data_counter <= 'b0;
                cs1 <= 1'b1;
                cs2 <= 1'b0;
                di <= 1'b0;  // Instrucción
                // SET_PAGE_0 + page_counter: 1011 1XXX
                data <= SET_PAGE_0 | page_counter[2:0];
            end

            WR_DATA_CS1: begin
                cs1 <= 1'b1;
                cs2 <= 1'b0;
                di <= 1'b1;  // Dato gráfico
                // Dirección en graphic_mem: página × 64 + columna
                data <= graphic_mem[(page_counter * NUM_COLS * 2) + data_counter];
                data_counter <= data_counter + 1;
            end

            // CHIP 2
            CONFIG_CS2: begin
                cs1 <= 1'b0;
                cs2 <= 1'b1;
                di <= 1'b0;  // Instrucción
                data <= config_mem[command_counter];
                command_counter <= command_counter + 1;
            end

            SET_PG_CS2: begin
                command_counter <= 'b0;
                data_counter <= 'b0;
                cs1 <= 1'b0;
                cs2 <= 1'b1;
                di <= 1'b0;  // Instrucción
                data <= SET_PAGE_0 | page_counter[2:0];
            end

            WR_DATA_CS2: begin
                cs1 <= 1'b0;
                cs2 <= 1'b1;
                di <= 1'b1;  // Dato gráfico
                // Chip 2 ocupa la segunda mitad de graphic_mem
                data <= graphic_mem[NUM_COLS + (page_counter * NUM_COLS * 2) + data_counter];
                data_counter <= data_counter + 1;
            end

            NEXT_PG: begin
                data_counter <= 'b0;
                page_counter <= page_counter + 1;
                cs1 <= 1'b1;
                cs2 <= 1'b1;
                di <= 1'b0;
                data <= 'b0;
            end

            default: begin
                cs1 <= 1'b0;
                cs2 <= 1'b0;
                di <= 1'b0;
                data <= 'b0;
            end

        endcase
    end
end

endmodule

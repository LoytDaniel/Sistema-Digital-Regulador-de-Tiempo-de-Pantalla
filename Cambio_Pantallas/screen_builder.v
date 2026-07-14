module screen_builder #(
            parameter DATA_BITS = 8,
            parameter NUM_DATA_ALL = 1024,
            parameter CLOCK_FPGA = 50000000
)(
    input kids, password, menu, adult, setting,
    input [7:0] left_time [0:1],
    input [7:0] current_hr, current_min,
    input [2:0] num_ingresados,
    input pass_incorrecta,
    input clk, rstn,
    input [7:0] tiempo_hr, tiempo_min,
    input [7:0] inicio_hr, inicio_min,
    input [7:0] final_hr, final_min,
    input [1:0] posicion_fila, // 0: fila 1 (tiempo) 1: fila 2 (inicio) 2: fila 3 (final) 
    input [1:0] posicion_columna, // 0: columna 1 (decena hora) 1: columna 2 (unidades hora) 2: columna 3 (decena minuto) 3: columna 4 (unidades minuto)
    output reg [7:0] graphic_mem [0:1023]
);

reg [7:0] kids_mem [0:1023];
reg [7:0] adult_mem [0:1023];
reg [7:0] menu_mem [0:1023];
reg [7:0] password_mem [0:1023];
reg [7:0] setting_mem [0:1023];

reg [7:0] left_time_hr, left_time_min;
reg [7:0] pixel_asterisco [0:6];
reg [7:0] pixel_guion [0:6];


// Carga los archivos de cada pantalla al inicio
initial begin
    $readmemh("kids.txt",kids_mem);
    $readmemh("adult.txt",adult_mem);
    $readmemh("menu.txt",menu_mem);
    $readmemh("password.txt",password_mem);
    $readmemh("setting.txt",setting_mem);
    pixel_asterisco = {8'h00, 8'h14, 8'h08, 8'h3E, 8'h08, 8'h14, 8'h00};
    pixel_guion = {8'h00, 8'h40, 8'h40, 8'h40, 8'h40, 8'h40, 8'h00};

end

always @(*) begin //Separa left_time en horas y minutos para decodificarlo a pixel
    left_time_hr = left_time[1];
    left_time_min = left_time[0];
end

//Contador para el parpadeo del cursor en la pantalla de configuración
reg [24:0] blink_cnt;
reg cursor_visible;

always @(posedge clk) begin
    if (!rstn) begin
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


//Decodificadores de BCD a pixel para left_time_hr
reg [7:0] left_time_hr_pixel_dec [0:6];
reg [7:0] left_time_hr_pixel_uni [0:6];

Decod_BCD_to_Pixel left_time_hr_1(
    .bcd(left_time_hr[7:4]),
    .num_data(left_time_hr_pixel_dec)
);

Decod_BCD_to_Pixel left_time_hr_2(
    .bcd(left_time_hr[3:0]),
    .num_data(left_time_hr_pixel_uni)
);

//Decodificadores de BCD a pixel para left_time_min
reg [7:0] left_time_min_pixel_dec [0:6];
reg [7:0] left_time_min_pixel_uni [0:6];

Decod_BCD_to_Pixel left_time_min_1(
    .bcd(left_time_min[7:4]),
    .num_data(left_time_min_pixel_dec)
);

Decod_BCD_to_Pixel left_time_min_2(
    .bcd(left_time_min[3:0]),
    .num_data(left_time_min_pixel_uni)
);

//Decodificadores de BCD a pixel para current_hr
reg [7:0] current_hr_pixel_dec [0:6];
reg [7:0] current_hr_pixel_uni [0:6];

Decod_BCD_to_Pixel current_hr_1(
    .bcd(current_hr[7:4]),
    .num_data(current_hr_pixel_dec)
);

Decod_BCD_to_Pixel current_hr_2(
    .bcd(current_hr[3:0]),
    .num_data(current_hr_pixel_uni)
);

//Decodificadores de BCD a pixel para current_min
reg [7:0] current_min_pixel_dec [0:6];
reg [7:0] current_min_pixel_uni [0:6];
Decod_BCD_to_Pixel current_min_1(
    .bcd(current_min[7:4]),
    .num_data(current_min_pixel_dec)
);

Decod_BCD_to_Pixel current_min_2(
    .bcd(current_min[3:0]),
    .num_data(current_min_pixel_uni)
);

//Decodificadores de BCD a pixel para tiempo_hr
reg [7:0] tiempo_hr_pixel_dec [0:6];
reg [7:0] tiempo_hr_pixel_uni [0:6];

    Decod_BCD_to_Pixel tiempo_hr_1(
        .bcd(tiempo_hr[7:4]),
        .num_data(tiempo_hr_pixel_dec)
    );

    Decod_BCD_to_Pixel tiempo_hr_2(
        .bcd(tiempo_hr[3:0]),
        .num_data(tiempo_hr_pixel_uni)
    );  

//Decodificadores de BCD a pixel para tiempo_min
reg [7:0] tiempo_min_pixel_dec [0:6];
reg [7:0] tiempo_min_pixel_uni [0:6];

    Decod_BCD_to_Pixel tiempo_min_1(
        .bcd(tiempo_min[7:4]),
        .num_data(tiempo_min_pixel_dec)
    );

    Decod_BCD_to_Pixel tiempo_min_2(
        .bcd(tiempo_min[3:0]),
        .num_data(tiempo_min_pixel_uni)
    );

//Decodificadores de BCD a pixel para inicio_hr
reg [7:0] inicio_hr_pixel_dec [0:6];
reg [7:0] inicio_hr_pixel_uni [0:6];

    Decod_BCD_to_Pixel inicio_hr_1(
        .bcd(inicio_hr[7:4]),
        .num_data(inicio_hr_pixel_dec)
    );

    Decod_BCD_to_Pixel inicio_hr_2(
        .bcd(inicio_hr[3:0]),
        .num_data(inicio_hr_pixel_uni)
    );

//Decodificadores de BCD a pixel para inicio_min
reg [7:0] inicio_min_pixel_dec [0:6];
reg [7:0] inicio_min_pixel_uni [0:6];

    Decod_BCD_to_Pixel inicio_min_1(
        .bcd(inicio_min[7:4]),
        .num_data(inicio_min_pixel_dec)
    );

    Decod_BCD_to_Pixel inicio_min_2(
        .bcd(inicio_min[3:0]),
        .num_data(inicio_min_pixel_uni)
    );

//Decodificadores de BCD a pixel para final_hr
reg [7:0] final_hr_pixel_dec [0:6];
reg [7:0] final_hr_pixel_uni [0:6];

    Decod_BCD_to_Pixel final_hr_1(
        .bcd(final_hr[7:4]),
        .num_data(final_hr_pixel_dec)
    );

    Decod_BCD_to_Pixel final_hr_2(
        .bcd(final_hr[3:0]),
        .num_data(final_hr_pixel_uni)
    );

//Decodificadores de BCD a pixel para final_min
reg [7:0] final_min_pixel_dec [0:6];
reg [7:0] final_min_pixel_uni [0:6];

    Decod_BCD_to_Pixel final_min_1(
        .bcd(final_min[7:4]),
        .num_data(final_min_pixel_dec)
    );

    Decod_BCD_to_Pixel final_min_2(
        .bcd(final_min[3:0]),
        .num_data(final_min_pixel_uni)
    );

integer i, j;

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
            graphic_mem[430+j]=left_time_hr_pixel_dec[j];
            graphic_mem[437+j]=left_time_hr_pixel_uni[j];
            graphic_mem[448+j]=left_time_min_pixel_dec[j];
            graphic_mem[455+j]=left_time_min_pixel_uni[j];
        end
    end
    else if (password) begin
        if (pass_incorrecta) begin
            for (j = 0; j < 7; j = j + 1) begin  //Cargar los guiones si la contraseña es incorrecta
            graphic_mem[307+j] = pixel_guion[j];
            graphic_mem[314+j] = pixel_guion[j];
            graphic_mem[321+j] = pixel_guion[j];
            graphic_mem[328+j] = pixel_guion[j];
            end
        end else begin
            for (j = 0; j < 128; j = j + 1) begin  //Quitar la linea de contraseña incorrecta
                graphic_mem[384+j]=password_mem[128+j];
            end
        end 
        for (j = 0; j < 7; j = j + 1) begin  //Cargar los asteriscos o guiones dependiendo del número de dígitos ingresados
            graphic_mem[307+j] = (num_ingresados >= 1) ? pixel_asterisco[j] : pixel_guion[j];
            graphic_mem[314+j] = (num_ingresados >= 2) ? pixel_asterisco[j] : pixel_guion[j];
            graphic_mem[321+j] = (num_ingresados >= 3) ? pixel_asterisco[j] : pixel_guion[j];
            graphic_mem[328+j] = (num_ingresados >= 4) ? pixel_asterisco[j] : pixel_guion[j];
        end 
    end
    else if (adult) begin
        for (j = 0; j < 7; j = j + 1) begin
            graphic_mem[430+j]=left_time_hr_pixel_dec[j];
            graphic_mem[437+j]=left_time_hr_pixel_uni[j];
            graphic_mem[448+j]=left_time_min_pixel_dec[j];
            graphic_mem[455+j]=left_time_min_pixel_uni[j];
        end
    end
    else if (setting) begin
        for (j = 0; j < 7; j = j + 1) begin
            graphic_mem[309+j]=tiempo_hr_pixel_dec[j];
            graphic_mem[316+j]=tiempo_hr_pixel_uni[j];
            graphic_mem[327+j]=tiempo_min_pixel_dec[j];
            graphic_mem[334+j]=tiempo_min_pixel_uni[j];
            graphic_mem[444+j]=inicio_hr_pixel_dec[j];
            graphic_mem[451+j]=inicio_hr_pixel_uni[j];
            graphic_mem[462+j]=inicio_min_pixel_dec[j];
            graphic_mem[469+j]=inicio_min_pixel_uni[j];
            graphic_mem[558+j]=final_hr_pixel_dec[j];
            graphic_mem[565+j]=final_hr_pixel_uni[j];
            graphic_mem[576+j]=final_min_pixel_dec[j];
            graphic_mem[583+j]=final_min_pixel_uni[j];
        end
        if(!cursor_visible) begin
            for (j = 0; j < 7; j = j + 1) begin
                if(posicion_fila == 2'b00) begin //Fila 1 (tiempo)
                    if(posicion_columna == 2'b00) graphic_mem[309+j]=pixel_guion[j];;
                    else if(posicion_columna == 2'b01) graphic_mem[316+j]=pixel_guion[j];
                    else if(posicion_columna == 2'b10) graphic_mem[327+j]=pixel_guion[j];
                    else if(posicion_columna == 2'b11) graphic_mem[334+j]=pixel_guion[j];
                end
                else if(posicion_fila == 2'b01) begin //Fila 2 (inicio)
                    if(posicion_columna == 2'b00) graphic_mem[444+j]=pixel_guion[j];
                    else if(posicion_columna == 2'b01) graphic_mem[451+j]=pixel_guion[j];
                    else if(posicion_columna == 2'b10) graphic_mem[462+j]=pixel_guion[j];
                    else if(posicion_columna == 2'b11) graphic_mem[469+j]=pixel_guion[j];
                end
                else if(posicion_fila == 2'b10) begin //Fila 3 (final)
                    if(posicion_columna == 2'b00) graphic_mem[558+j]=pixel_guion[j];
                    else if(posicion_columna == 2'b01) graphic_mem[565+j]=pixel_guion[j];
                    else if(posicion_columna == 2'b10) graphic_mem[576+j]=pixel_guion[j];
                    else if(posicion_columna == 2'b11) graphic_mem[583+j]=pixel_guion[j];
                end
            end
        end
    end

end

endmodule
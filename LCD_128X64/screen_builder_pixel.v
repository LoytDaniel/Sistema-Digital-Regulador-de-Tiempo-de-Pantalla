module screen_builder_pixel (
    input [7:0] left_time_H, left_time_M,
    input [7:0] current_hr, current_time_min,
    input [7:0] tiempo_hr, tiempo_min,
    input [7:0] inicio_hr, inicio_min,
    input [7:0] final_hr, final_min,
    output [55:0] left_time_hr_pixel_dec, left_time_hr_pixel_uni,
    output [55:0] left_time_min_pixel_dec, left_time_min_pixel_uni,
    output [55:0] current_hr_pixel_dec, current_hr_pixel_uni,
    output [55:0] current_min_pixel_dec, current_min_pixel_uni,
    output [55:0] tiempo_hr_pixel_dec, tiempo_hr_pixel_uni,
    output [55:0] tiempo_min_pixel_dec, tiempo_min_pixel_uni,
    output [55:0] inicio_hr_pixel_dec, inicio_hr_pixel_uni,
    output [55:0] inicio_min_pixel_dec, inicio_min_pixel_uni,
    output [55:0] final_hr_pixel_dec, final_hr_pixel_uni,
    output [55:0] final_min_pixel_dec, final_min_pixel_uni
);
    
//Decodificadores de BCD a pixel para left_time_hr
Decod_BCD_to_Pixel left_time_hr_1(
    .bcd(left_time_H[7:4]),
    .num_data(left_time_hr_pixel_dec)
);

Decod_BCD_to_Pixel left_time_hr_2(
    .bcd(left_time_H[3:0]),
    .num_data(left_time_hr_pixel_uni)
);

//Decodificadores de BCD a pixel para left_time_min
Decod_BCD_to_Pixel left_time_min_1(
    .bcd(left_time_M[7:4]),
    .num_data(left_time_min_pixel_dec)
);

Decod_BCD_to_Pixel left_time_min_2(
    .bcd(left_time_M[3:0]),
    .num_data(left_time_min_pixel_uni)
);

//Decodificadores de BCD a pixel para current_hr
Decod_BCD_to_Pixel current_hr_1(
    .bcd(current_hr[7:4]),
    .num_data(current_hr_pixel_dec)
);

Decod_BCD_to_Pixel current_hr_2(
    .bcd(current_hr[3:0]),
    .num_data(current_hr_pixel_uni)
);

//Decodificadores de BCD a pixel para current_min
Decod_BCD_to_Pixel current_min_1(
    .bcd(current_min[7:4]),
    .num_data(current_min_pixel_dec)
);

Decod_BCD_to_Pixel current_min_2(
    .bcd(current_min[3:0]),
    .num_data(current_min_pixel_uni)
);

//Decodificadores de BCD a pixel para tiempo_hr
    Decod_BCD_to_Pixel tiempo_hr_1(
        .bcd(tiempo_hr[7:4]),
        .num_data(tiempo_hr_pixel_dec)
    );

    Decod_BCD_to_Pixel tiempo_hr_2(
        .bcd(tiempo_hr[3:0]),
        .num_data(tiempo_hr_pixel_uni)
    );  

//Decodificadores de BCD a pixel para tiempo_min
    Decod_BCD_to_Pixel tiempo_min_1(
        .bcd(tiempo_min[7:4]),
        .num_data(tiempo_min_pixel_dec)
    );

    Decod_BCD_to_Pixel tiempo_min_2(
        .bcd(tiempo_min[3:0]),
        .num_data(tiempo_min_pixel_uni)
    );

//Decodificadores de BCD a pixel para inicio_hr
    Decod_BCD_to_Pixel inicio_hr_1(
        .bcd(inicio_hr[7:4]),
        .num_data(inicio_hr_pixel_dec)
    );

    Decod_BCD_to_Pixel inicio_hr_2(
        .bcd(inicio_hr[3:0]),
        .num_data(inicio_hr_pixel_uni)
    );

//Decodificadores de BCD a pixel para inicio_min
    Decod_BCD_to_Pixel inicio_min_1(
        .bcd(inicio_min[7:4]),
        .num_data(inicio_min_pixel_dec)
    );

    Decod_BCD_to_Pixel inicio_min_2(
        .bcd(inicio_min[3:0]),
        .num_data(inicio_min_pixel_uni)
    );

//Decodificadores de BCD a pixel para final_hr
    Decod_BCD_to_Pixel final_hr_1(
        .bcd(final_hr[7:4]),
        .num_data(final_hr_pixel_dec)
    );

    Decod_BCD_to_Pixel final_hr_2(
        .bcd(final_hr[3:0]),
        .num_data(final_hr_pixel_uni)
    );

//Decodificadores de BCD a pixel para final_min
    Decod_BCD_to_Pixel final_min_1(
        .bcd(final_min[7:4]),
        .num_data(final_min_pixel_dec)
    );

    Decod_BCD_to_Pixel final_min_2(
        .bcd(final_min[3:0]),
        .num_data(final_min_pixel_uni)
    );

endmodule
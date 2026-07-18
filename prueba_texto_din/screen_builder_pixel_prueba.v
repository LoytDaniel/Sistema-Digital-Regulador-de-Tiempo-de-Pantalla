module screen_builder_pixel_prueba (
    input [7:0] current_hr, current_min,
    output [55:0] current_hr_pixel_dec, current_hr_pixel_uni,
    output [55:0] current_min_pixel_dec, current_min_pixel_uni
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

endmodule
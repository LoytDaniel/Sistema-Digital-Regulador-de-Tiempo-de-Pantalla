module screen_builder_pixel_p3 (
    input [7:0] left_time_H, left_time_M,
    output [55:0] left_time_hr_pixel_dec, left_time_hr_pixel_uni,
    output [55:0] left_time_min_pixel_dec, left_time_min_pixel_uni
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

endmodule
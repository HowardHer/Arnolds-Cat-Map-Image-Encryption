#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "Arnoldfns.h"
#include <math.h>
#include <time.h>

// To run the program, use the following command (where bigbf.bmp is the input image name):
//      make
//      ./Arnold.out bigbf.bmp

int main(int argc, char *argv[]) {
    FILE *input = fopen(argv[1], "rb");
    FILE *resized = fopen("./output/resized_img.bmp", "wb");
    FILE *encrypted = fopen("./output/encrypted_img.bmp", "wb");
    FILE *decrypted = fopen("./output/decrypted_img.bmp", "wb");
    extern uint8_t header[54];

    struct BMPfile BMP;                 //declare a struct for the original RGB BMP file
    struct gray_BMPfile NEW_BMP;        //declare a struct for the new gray scale BMP file
    struct gray_BMPfile ENCRYPTED_BMP;
    struct gray_BMPfile DECRYPTED_BMP;

    BMP.head = read_header(input);     //read the header from the input file
    NEW_BMP.head = BMP.head;           //copy header information

    if(NEW_BMP.head.BMPbits_per_pixel == 8){
        printf("input image is grayscale already\n");
        NEW_BMP.data = read_gray_data(input);
    }
    else if(NEW_BMP.head.BMPbits_per_pixel == 24){
        BMP.data = read_data(input);       //read the RGB color from the input file
        //modify the header information according to the format of gray scale BMP file
        NEW_BMP.head.BMPbits_per_pixel = 8;
        NEW_BMP.head.BMPnumber_color_used = 256;
        NEW_BMP.head.BMPdata_offset = 1078;
        NEW_BMP.head.BMPpixeldata_size = NEW_BMP.head.BMPbitmap_width*NEW_BMP.head.BMPbitmap_height;
        NEW_BMP.head.BMPfile_len = 54 + 4*256 + (NEW_BMP.head.BMPbitmap_width+gray_padding(NEW_BMP.head.BMPbitmap_width))*NEW_BMP.head.BMPbitmap_height;
        NEW_BMP.data = transform_color(BMP);    //transform the color data from RGB to gray scale
    }
    
    // Resize
    int width = 30;
    int height = 30;
    NEW_BMP.data = resize(NEW_BMP, width, height);
    NEW_BMP.head.BMPbitmap_width = width;
    NEW_BMP.head.BMPbitmap_height = height;
    write_gray_BMP(NEW_BMP, resized);        //write the information to the resized_img.bmp

    clock_t start, end;
    long double cpu_time_used;

    // Encryption
    start = clock();

    ArnoldCatEncryption(&NEW_BMP, 20);
    ENCRYPTED_BMP.head = NEW_BMP.head;
    ENCRYPTED_BMP.data = NEW_BMP.data;
    write_gray_BMP(ENCRYPTED_BMP, encrypted);

    end = clock();
    cpu_time_used = ((long double) (end - start)) / CLOCKS_PER_SEC;
    printf("Encryption takes %Lf seconds\n", cpu_time_used);

    // Decryption
    start = clock();

    DECRYPTED_BMP.head = ENCRYPTED_BMP.head;
    DECRYPTED_BMP.data = ENCRYPTED_BMP.data;
    ArnoldCatDecryption(&DECRYPTED_BMP, 20);
    write_gray_BMP(DECRYPTED_BMP, decrypted);

    end = clock();
    cpu_time_used = ((long double) (end - start)) / CLOCKS_PER_SEC;
    printf("Decryption takes %Lf seconds\n", cpu_time_used);

    fclose(input);
    fclose(resized);
    fclose(encrypted);
    fclose(decrypted);
    return 0;
}
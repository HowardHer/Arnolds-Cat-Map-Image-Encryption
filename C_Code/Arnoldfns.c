#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "Arnoldfns.h"
#include <math.h>
uint8_t header[54];

struct BMPheader read_header(FILE *fp){
    struct BMPheader headerinfo;

    fread(header, 1, 54, fp);

    headerinfo.BMPid_mark = get_header_value("BMPid_mark", header);
    headerinfo.BMPfile_len = get_header_value("BMPfile_len", header);
    headerinfo.BMPreserved = get_header_value("BMPreserved", header);
    headerinfo.BMPdata_offset = get_header_value("BMPdata_offset", header);
    headerinfo.BMPhdr_size = get_header_value("BMPhdr_size", header);
    headerinfo.BMPbitmap_width = get_header_value("BMPbitmap_width", header);
    headerinfo.BMPbitmap_height = get_header_value("BMPbitmap_height", header);
    headerinfo.BMPnum_colorplanes = get_header_value("BMPnum_colorplanes", header);
    headerinfo.BMPbits_per_pixel = get_header_value("BMPbits_per_pixel", header);
    headerinfo.BMPcompression_mode = get_header_value("BMPcompression_mode", header);
    headerinfo.BMPpixeldata_size = get_header_value("BMPpixeldata_size", header);
    headerinfo.BMPpixels_per_meter_horizontal = get_header_value("BMPpixels_per_meter_horizontal", header);
    headerinfo.BMPpixels_per_meter_vertical = get_header_value("BMPpixels_per_meter_vertical", header);
    headerinfo.BMPnumber_color_used = get_header_value("BMPnumber_color_used", header);
    headerinfo.BMPnumber_important_colors = get_header_value("BMPnumber_important_colors", header);

    return headerinfo;
}

struct bgr_pixel *read_data(FILE *fp){
    struct bgr_pixel *data;
    uint32_t width = get_header_value("BMPbitmap_width", header);
    uint32_t height = get_header_value("BMPbitmap_height", header);

    data = malloc(width*height*sizeof(struct bgr_pixel));
    fseek(fp,get_header_value("BMPdata_offset",header),SEEK_SET);

    int row, col, pad;
    for(row = 0; row < height; row++){
        for(col = 0; col < width; col++){
            data[row*width+col].blu = fgetc(fp);
            data[row*width+col].grn = fgetc(fp);
            data[row*width+col].red = fgetc(fp);
        }
        for(pad = 0; pad < padding(width); pad++){
            fgetc(fp);
        }
    }
    return data;
}

struct gray_pixel *read_gray_data(FILE *fp){
    struct gray_pixel *data;
    uint32_t width = get_header_value("BMPbitmap_width", header);
    uint32_t height = get_header_value("BMPbitmap_height", header);

    data = malloc(width*height*sizeof(struct gray_pixel));
    fseek(fp,get_header_value("BMPdata_offset",header),SEEK_SET);

    int row, col, pad;
    for(row = 0; row < height; row++){
        for(col = 0; col < width; col++){
            data[row*width+col].gray = fgetc(fp);
        }
        for(pad = 0; pad < gray_padding(width); pad++){
            fgetc(fp);
        }
    }
    return data;
}

struct gray_pixel *transform_color(struct BMPfile BMP){
    struct gray_pixel *g_pixel;
    int width = BMP.head.BMPbitmap_width;
    int height = BMP.head.BMPbitmap_height;
    g_pixel = malloc(sizeof(uint8_t)*width*height);

    int row, col;
    for(row = 0; row < height; row++){
        for(col = 0; col < width; col++){
            int index = row*width+col;
            g_pixel[index].gray = (BMP.data[index].blu+BMP.data[index].grn+BMP.data[index].red)/3;
        }
    }

    return g_pixel;
}

// nn_resize modified from EE 576
struct gray_pixel *resize(struct gray_BMPfile BMP, int n_width, int n_height){
    struct gray_pixel *g_pixel;
    int orig_width = BMP.head.BMPbitmap_width;
    int orig_height = BMP.head.BMPbitmap_height;

    g_pixel = malloc(sizeof(uint8_t)*n_width*n_height);

    float a1 = 0, b1 = 0;
    float a2 = 0, b2 = 0;

    a1 = (float)orig_width/n_width;
    b1 = (float)orig_width/(2*n_width)-0.5;
    a2 = (float)orig_height/n_height;
    b2 = (float)orig_height/(2*n_height)-0.5;
    int row, col;
    for(col = 0; col < n_width; col++){
      for(row = 0; row < n_height; row++){
        int index = round(a2*row+b2)*orig_width + round(a1*col+b1);
        g_pixel[row*n_width + col].gray = BMP.data[index].gray;
        }
      }

    return g_pixel;
}

void ArnoldCatTransform(struct gray_BMPfile *grayBMP){
    int x, y;
    int cols = grayBMP->head.BMPbitmap_width;
    int rows = grayBMP->head.BMPbitmap_height;
    struct gray_pixel *g_pixel = malloc(sizeof(uint8_t)*cols*rows);

    for(x = 0; x < cols; x++){
        for(y = 0; y < rows; y++){
            int nx = (x+y)%rows;
            int ny = (x+2*y)%cols;
            g_pixel[y*cols + x].gray = grayBMP->data[ny*cols + nx].gray;
        }
    }
    grayBMP->data = g_pixel;
}

void ArnoldCatEncryption(struct gray_BMPfile *grayBMP, int key){
    int i;
    for(i = 0; i < key; i++){
        ArnoldCatTransform(grayBMP);
    }
}

void ArnoldCatDecryption(struct gray_BMPfile *grayBMP, int key){
    int dimensions = grayBMP->head.BMPbitmap_height;
    int decrypt_it = dimensions;
    if((dimensions % 2 == 0) && pow(5, (int)(round(log((float)dimensions/2)/log(5)))) == (int)((float)dimensions/2)){
        decrypt_it = dimensions*3;
    }else if(pow(5, (int)(round(log((float)dimensions/2)/log(5)))) == (int)((float)dimensions/2)){
        decrypt_it = dimensions*2;
    }else if(dimensions % 6 == 0 && pow(5, (int)(round(log((float)dimensions/6)/log(5)))) == (int)((float)dimensions/6)){
        decrypt_it = dimensions*2;
    }else{
        decrypt_it = (int)(12*(float)dimensions/7);
    }
    for(int i = key; i < decrypt_it; i++){
        ArnoldCatTransform(grayBMP);
    }
}

void write_gray_BMP(struct gray_BMPfile gray_BMP, FILE *fp){
    write2LE(gray_BMP.head.BMPid_mark, fp);
    write4LE(gray_BMP.head.BMPfile_len, fp);
    write4LE(gray_BMP.head.BMPreserved, fp);
    write4LE(gray_BMP.head.BMPdata_offset, fp);
    write4LE(gray_BMP.head.BMPhdr_size, fp);
    write4LE(gray_BMP.head.BMPbitmap_width, fp);
    write4LE(gray_BMP.head.BMPbitmap_height, fp);
    write2LE(gray_BMP.head.BMPnum_colorplanes, fp);
    write2LE(gray_BMP.head.BMPbits_per_pixel, fp);
    write4LE(gray_BMP.head.BMPcompression_mode, fp);
    write4LE(gray_BMP.head.BMPpixeldata_size, fp);
    write4LE(gray_BMP.head.BMPpixels_per_meter_horizontal, fp);
    write4LE(gray_BMP.head.BMPpixels_per_meter_vertical, fp);
    write4LE(gray_BMP.head.BMPnumber_color_used, fp);
    write4LE(gray_BMP.head.BMPnumber_important_colors, fp);

    print_gray_table(fp);

    int row, col, pad;
    int width = gray_BMP.head.BMPbitmap_width;
    int height = gray_BMP.head.BMPbitmap_height;

    for(row = 0; row < height; row++){
        for(col = 0; col < width; col++){
            fputc(gray_BMP.data[row*width+col].gray, fp);
        }
        for(pad = 0; pad < gray_padding(width); pad++){
            fputc(0,fp);
        }
    }
}

void print_gray_table(FILE *fp){
    int i;
    for(i = 0; i < 256; i++){
        fputc(i,fp);
        fputc(i,fp);
        fputc(i,fp);
        fputc(0,fp);
    }
}

uint32_t get_header_value(char field[], uint8_t header[54]){
    uint32_t val = 0;


    if(strcmp(field, "BMPid_mark") == 0){
        val = header[0];
        val |= header[1] << 8;
    }else if(strcmp(field, "BMPfile_len") == 0){
        val = header[2];
        val |= header[3] << 8;
        val |= header[4] << 8;
        val |= header[5] << 8;
    }else if(strcmp(field, "BMPreserved") == 0){
        val = header[6];
        val |= header[7] << 8;
        val |= header[8] << 8;
        val |= header[9] << 8;
    }else if(strcmp(field, "BMPdata_offset") == 0){
        val = header[10];
        val |= header[11] << 8;
        val |= header[12] << 8;
        val |= header[13] << 8;
    }else if(strcmp(field, "BMPhdr_size") == 0){
        val = header[14];
        val |= header[15] << 8;
        val |= header[16] << 8;
        val |= header[17] << 8;
    }else if(strcmp(field, "BMPbitmap_width") == 0){
        val = header[18];
        val |= header[19] << 8;
        val |= header[20] << 8;
        val |= header[21] << 8;
    }else if(strcmp(field, "BMPbitmap_height") == 0){
        val = header[22];
        val |= header[23] << 8;
        val |= header[24] << 8;
        val |= header[25] << 8;
    }else if(strcmp(field, "BMPnum_colorplanes") == 0){
        val = header[26];
        val |= header[27] << 8;
    }else if(strcmp(field, "BMPbits_per_pixel") == 0){
        val = header[28];
        val |= header[29] << 8;
    }else if(strcmp(field, "BMPcompression_mode") == 0){
        val = header[30];
        val |= header[31] << 8;
        val |= header[32] << 8;
        val |= header[33] << 8;
    }else if(strcmp(field, "BMPpixeldata_size") == 0){
        val = header[34];
        val |= header[35] << 8;
        val |= header[36] << 8;
        val |= header[37] << 8;
    }else if(strcmp(field, "BMPpixels_per_meter_horizontal") == 0){
        val = header[38];
        val |= header[39] << 8;
        val |= header[40] << 8;
        val |= header[41] << 8;
    }else if(strcmp(field, "BMPpixels_per_meter_vertical") == 0){
        val = header[42];
        val |= header[43] << 8;
        val |= header[44] << 8;
        val |= header[45] << 8;
    }else if(strcmp(field, "BMPnumber_color_used") == 0){
        val = header[46];
        val |= header[47] << 8;
        val |= header[48] << 8;
        val |= header[49] << 8;
    }else if(strcmp(field, "BMPnumber_important_colors") == 0){
        val = header[50];
        val |= header[51] << 8;
        val |= header[52] << 8;
        val |= header[53] << 8;
    }
    return val;
}

int gray_padding(uint32_t ncols){//number of bytes of padding to add to the end of each pixel row
    uint64_t current_bytes;
    int remainder;
    current_bytes = ncols;
    remainder = current_bytes % 4;
    if(remainder == 3){
        return 1;
    }else if(remainder == 2){
        return 2;
    }else if(remainder == 1){
        return 3;
    }else{
        return 0;
    }
}

void write4LE(unsigned int val, FILE *fp){ //write four bytes of val little-endian to a file, exit if error

    int b1, b2, b3, b4;
    b1 = val % 256;
    val = val / 256;
    b2 = val % 256;
    val = val / 256;
    b3 = val % 256;
    val = val / 256;
    b4 = val % 256;
    fputc(b1, fp);
    fputc(b2, fp);
    fputc(b3, fp);
    fputc(b4, fp);

}

void write2LE(unsigned int val, FILE *fp){ //write two bytes of val little-endian to a file, exit if error

    int b1, b2;
    b1 = val % 256;
    val = val / 256;
    b2 = val % 256;
    fputc(b1,fp);
    fputc(b2,fp);

}

int padding(uint32_t ncols){//number of bytes of padding to add to the end of each pixel row
    uint32_t current_bytes;
    int remainder;
    current_bytes = 3*ncols;
    remainder = current_bytes % 4;
    if(remainder == 3){
        return 1;
    }else if(remainder == 2){
        return 2;
    }
    else if(remainder == 1){
        return 3;
    }
    else{
        return 0;
    }
}

void writePIXEL(int red, int grn, int blu, FILE *fp){ //write next pixel to bmp image
    fputc(blu,fp);
    fputc(grn,fp);
    fputc(red,fp);
}

void writePAD(int pad, FILE *fp){ //write bmp image line-padding
    int i;
    for(i = 0; i < pad; i++){
        fputc(0, fp);
    }
}

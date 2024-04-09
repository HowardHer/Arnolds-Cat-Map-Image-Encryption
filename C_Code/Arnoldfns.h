// #ifndef PROBLEM2_BMP24RGBTO8GSFNS_H
// #define PROBLEM2_BMP24RGBTO8GSFNS_H

// #endif //PROBLEM2_BMP24RGBTO8GSFNS_H
#include<stdint.h>

// header struct
struct BMPheader {
    uint16_t BMPid_mark;
    uint32_t BMPfile_len;
    uint32_t BMPreserved;
    uint32_t BMPdata_offset;
    uint32_t BMPhdr_size;
    uint32_t BMPbitmap_width;
    uint32_t BMPbitmap_height;
    uint16_t BMPnum_colorplanes;
    uint16_t BMPbits_per_pixel;
    uint32_t BMPcompression_mode;
    uint32_t BMPpixeldata_size;
    uint32_t BMPpixels_per_meter_horizontal;
    uint32_t BMPpixels_per_meter_vertical;
    uint32_t BMPnumber_color_used;
    uint32_t BMPnumber_important_colors;
};
//RGB pixel struct
struct bgr_pixel {
    uint8_t blu;
    uint8_t grn;
    uint8_t red;
};

//gray pixel struct
struct gray_pixel {
    uint8_t gray;
};

//RGB BMP file struct
struct BMPfile {
    struct BMPheader head;
    struct bgr_pixel *data;
};

//gray scale BMP file struct
struct gray_BMPfile {
    struct BMPheader head;
    struct gray_pixel *data;
};

struct gray_pixel *resize(struct gray_BMPfile BMP, int n_width, int n_height);

void ArnoldCatTransform(struct gray_BMPfile *grayBMP);

void ArnoldCatEncryption(struct gray_BMPfile *grayBMP, int key);

void ArnoldCatDecryption(struct gray_BMPfile *grayBMP, int key);

struct bgr_pixel *read_data(FILE *fp); //read the color data from the given file into a struct pointer, and return the struct pointer

struct gray_pixel *read_gray_data(FILE *fp); //read gray bmp color data

struct BMPheader read_header(FILE *fp); //read the header information from the input file

void write_gray_BMP(struct gray_BMPfile gray_BMP, FILE *fp); //write all the information to the ouput file

void print_gray_table(FILE *fp); //print out gray scale table

struct gray_pixel *transform_color(struct BMPfile BMP); //transform the rgb pixel array to gray scale pixel array

uint32_t get_header_value(char field[], uint8_t header[]); //get header value

int gray_padding(uint32_t ncols); //number of bytes of padding to add to the end of each pixel row

int padding(uint32_t ncols);// count the number of paddings

void write4LE(unsigned int val, FILE *fp); //write four bytes of val little-endian to a file, exit if error

void write2LE(unsigned int val, FILE *fp); //write two bytes of val little-endian to a file, exit if error

void writePIXEL(int red, int grn, int blu, FILE *fp); //write next pixel to bmp image

void writePAD(int pad, FILE *fp); //write bmp image line-padding
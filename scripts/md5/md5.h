// Copyright 2020-2021 The jdh99 Authors. All rights reserved.
// calc md5
// Authors: jdh99 <jdh821@163.com>

#ifndef MD5_H
#define MD5_H

#include <stdint.h>

// MD5 len
#define MD5_LEN 16

typedef struct
{
    unsigned int count[2];
    unsigned int state[4];
    unsigned char buffer[64];
} MD5_CTX;

void MD5Init(MD5_CTX* context);
void MD5Update(MD5_CTX* context, unsigned char* input, unsigned int inputlen);
void MD5Final(MD5_CTX* context, unsigned char digest[16]);
void MD5Transform(unsigned int state[4], unsigned char block[64]);
void MD5Encode(unsigned char* output, unsigned int* input, unsigned int len);
void MD5Decode(unsigned int* output, unsigned char* input, unsigned int len);

// MD5Calc calc md5
// out is md5 result.Notice out array size is greater than 16
void MD5Calc(uint8_t* data, int len, uint8_t* out);

#endif
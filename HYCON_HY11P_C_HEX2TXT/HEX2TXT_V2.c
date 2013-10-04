/*
    The MIT License (MIT)

    Copyright (c) 2013 Hank Wei(Pamers, Inc.)

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <dirent.h>

int file2HexCSV(char *path, char *fileName)
{
    FILE *Ofile = fopen(path, "rb");
    FILE *STFileE;

    if(Ofile == 0)
    {
        return 0;
    }
    else
    {
       /*
        fseek(Ofile, 0, SEEK_END);
        long long int size = ftell(Ofile);
        fseek(Ofile, 0, SEEK_SET);
        printf("%d", size); */

        STFileE = fopen(fileName, "w");
        unsigned char str[16];
        int i = 0, j = 0;
        unsigned long int k = 0;
        printf(" %-25s ----> %s\n", path, fileName);
        while(!feof(Ofile))
        {
            i = fread(str, sizeof(unsigned char), 16, Ofile);


                fprintf(STFileE, "0x%05XH,", k);

            for( j = 0 ; j < i ; ++j)
            {
                k++;
                fprintf(STFileE, "%02X,", str[j]);

                if( j == 7)
                {
                    fprintf(STFileE, ",");
                }

                if( j == 15)
                {
                    fprintf(STFileE, "\n");
                }
            }
        }
    }
    fclose(STFileE);
    fclose(Ofile);
    return 1;
}

int dir_recursive(char *path, FILE *output,char *mD)
{
    #ifdef _WIN32
    char Separ = '\\'; /*Windows �����j�Ÿ�*/
    #else
    char Separ = '/'; /*Linux �����j�Ÿ�*/
    #endif
    DIR * DataDir = opendir(path); /*�}�ҥؿ��ˬd*/
    struct dirent *filename;
    if(!DataDir) /*�}�ɦ��\*/
    {
        fprintf(output,"%s\n",path);

        char *txtF=".csv";
        long int Dir_Length = strlen(path) + strlen(path)+10;
        char *DirStr2 = (char*)malloc(sizeof(char) * Dir_Length);
        strcpy(DirStr2, mD);
        strcat(DirStr2, path);
        strcat(DirStr2, txtF); /*���O�O���骺�g�k*/
        file2HexCSV(path, DirStr2);
        return 0;
    }

    while((filename=readdir(DataDir)))
    {
        if(!strcmp(filename->d_name,"..") || !strcmp(filename->d_name,".") ||!strcmp(filename->d_name,""))
        {
            continue; /*���L��^�W�h�����ؿ�*/
        }
        long int Dir_Length = strlen(path) + strlen(filename->d_name)+10 ; /*�p����|�r�����*/
        char *DirStr = (char*)malloc(sizeof(char) * Dir_Length);
        long int i = strlen(DirStr);
        strcpy(DirStr, path); /*�ƻs�r���}�C*/

        if(DirStr[i - 1] != Separ) /*�ˬd�ؿ����j�Ÿ�*/
        {
            DirStr[i] = Separ;
            DirStr[i + 1] = '\0';
        }
        strcat(DirStr, filename->d_name); /*�걵�U�@���ɮצW�٨�s���}�C�Ŷ�*/
        dir_recursive(DirStr,output, mD); /*���j�u���ѤW��*/
    }

    closedir(DataDir); /*�����ؿ�*/
    return 1;
}


void main (int argc, char **argv)
{
    printf(" File2HEXTxt v0.03B by Hank Wei (hank_wei@pamers.com.tw)\n Copyright 2011 Pamers, Inc.  All Rights Reserved.\n");
    FILE *fileOut = fopen("output.txt", "w");
    char *mD="out";
    mkdir(mD);
    dir_recursive(".\\",fileOut, mD);
}

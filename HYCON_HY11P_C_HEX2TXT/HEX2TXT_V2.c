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
    char Separ = '\\'; /*Windows 的分隔符號*/
    #else
    char Separ = '/'; /*Linux 的分隔符號*/
    #endif
    DIR * DataDir = opendir(path); /*開啟目錄檢查*/
    struct dirent *filename;
    if(!DataDir) /*開檔成功*/
    {
        fprintf(output,"%s\n",path);

        char *txtF=".csv";
        long int Dir_Length = strlen(path) + strlen(path)+10;
        char *DirStr2 = (char*)malloc(sizeof(char) * Dir_Length);
        strcpy(DirStr2, mD);
        strcat(DirStr2, path);
        strcat(DirStr2, txtF); /*浪費記憶體的寫法*/
        file2HexCSV(path, DirStr2);
        return 0;
    }

    while((filename=readdir(DataDir)))
    {
        if(!strcmp(filename->d_name,"..") || !strcmp(filename->d_name,".") ||!strcmp(filename->d_name,""))
        {
            continue; /*跳過返回上層的母目錄*/
        }
        long int Dir_Length = strlen(path) + strlen(filename->d_name)+10 ; /*計算路徑字串長度*/
        char *DirStr = (char*)malloc(sizeof(char) * Dir_Length);
        long int i = strlen(DirStr);
        strcpy(DirStr, path); /*複製字串到陣列*/

        if(DirStr[i - 1] != Separ) /*檢查目錄分隔符號*/
        {
            DirStr[i] = Separ;
            DirStr[i + 1] = '\0';
        }
        strcat(DirStr, filename->d_name); /*串接下一個檔案名稱到新的陣列空間*/
        dir_recursive(DirStr,output, mD); /*遞迴只應天上有*/
    }

    closedir(DataDir); /*關閉目錄*/
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

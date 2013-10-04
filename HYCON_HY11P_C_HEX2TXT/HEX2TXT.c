#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/*
   Hank Wei ÃQ»¨«Û
   -std=c99
   ver: v0.01
   
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
void main (int argc, char **argv)
{
    system("cls");
    int sview = 0, esave = 0;
    esave = 1;
    printf(" File2HEXTxt v0.03 by Hank Wei (hank_wei@pamers.com.tw)\n Copyright 2011 Pamers, Inc.  All Rights Reserved.\n");
    for(int i = 0; i < argc; i++)
    {
        if(strcmp("/h", argv[i]) == 0)
        {
            printf("\n %s is a freeware hex viewer and save hex file text file, can running \n all GNU GCC compiler system.\n\n %s [filename] [/h] [/s] [/e]\n /h: About.\n /s: Save HEX file to out.txt.\n /e: Save HEX file to out.csv(EXCEL Mode) *DEF*.\n\n", argv[0], argv[0]);
        }
       /* if(strcmp("/e", argv[i]) == 0)
        {
            esave = 1;
        } */
        if(strcmp("/s", argv[i]) == 0)
        {
            sview = 1;
            esave = 0;
        }
    }

    FILE *Ofile = fopen(argv[1], "rb"), *STFileE, *STFile;

    if(Ofile == 0)
    {
        printf(" No File.\n");
        sview = 0;
        esave = 0;
    }
    else
    {
        printf(" Open File: %s... ", argv[1]);

        if(sview == 1)
        {
            char fileName[1023]= ".txt";
            strcat(argv[1], fileName);
            printf("Out File %s.",fileName);
            STFile = fopen(fileName, "w");
            fprintf(STFile, " File2HEXTxt v0.02 by Hank Wei (hank_wei@pamers.com.tw)\n Copyright 2011 Pamers, Inc.  All Rights Reserved.\n");
            fprintf(STFile, " Open File: %s... \n", argv[1]);
        }
        if(esave == 1)
        {
            printf("out.csv");
            STFileE = fopen(".csv", "w");
            fprintf(STFileE, "File2HEXTxt v0.01 by Hank Wei (hank_wei@pamers.com.tw). Copyright 2011 Pamers, Inc.  All Rights Reserved.\n");
            fprintf(STFileE, "Open File: %s... \n", argv[1]);
        }
        if(esave == 0 && sview == 0)
        {
            printf("View Mode. \n");
        }

        unsigned char str[16];
        int i = 0, j = 0;
        unsigned long int k = 0;
        printf("\n            +---------------------------------------------------+\n    OFFSET  | 00 01 02 03 04 05 06 07   08 09 0A 0B 0C 0D 0E 0F |\n +----------+---------------------------------------------------+\n ");

        if(sview == 1)
            fprintf(STFile, "            +---------------------------------------------------+\n    OFFSET  | 00 01 02 03 04 05 06 07   08 09 0A 0B 0C 0D 0E 0F |\n +----------+---------------------------------------------------+\n ");

        if(esave == 1)
            fprintf(STFileE, "---------------------------------------------------\nOFFSET,0,1,2,3,4,5,6,7,,8,9,A,B,C,D,E,F\n---------------------------------------------------\n");


        while(!feof(Ofile))
        {
            i = fread(str, sizeof(unsigned char), 16, Ofile);

            if(i < 16)
            {
                str[i] = '\0';
                printf("+----------+---------------------------------------------------+\n");
                if(sview == 1)
                    fprintf(STFile, "+----------+---------------------------------------------------+\n");
                if(esave == 1)
                    fprintf(STFileE, "---------------------------------------------------\n");
            }
            else
            {
                printf("| 0x%05XH | ", k);
                if(sview == 1)
                    fprintf(STFile, "| 0x%05XH | ", k);
                if(esave == 1)
                    fprintf(STFileE, "0x%05XH,", k);
            }

            for( j = 0 ; j < i ; ++j)
            {
                k++;
                printf("%02X ", str[j]);
                if(sview == 1)
                    fprintf(STFile, "%02X ", str[j]);
                if(esave == 1)
                    fprintf(STFileE, "%02X,", str[j]);

                if( j == 7)
                {
                    printf("- ");
                    if(sview == 1)
                        fprintf(STFile, "- ");
                    if(esave == 1)
                        fprintf(STFileE, ",");
                }

                if( j == 15)
                {
                    printf("|\n ");
                    if(sview == 1)
                        fprintf(STFile, "|\n ");
                    if(esave == 1)
                        fprintf(STFileE, "\n");
                }
            }
        }

        if(sview == 1)
        {
            fclose(STFile);
        }
        if(esave == 1)
        {
            fclose(STFileE);
        }
    }
    if(Ofile != 0)
        fclose(Ofile);

    system("pause");

}

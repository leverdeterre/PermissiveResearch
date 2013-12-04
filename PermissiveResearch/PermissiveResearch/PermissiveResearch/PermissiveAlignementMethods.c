//
//  PermissiveAlignementMethods.c
//  PermissiveSearch
//
//  Created by Jerome Morissard on 10/26/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#include <math.h>

#define MAX2(x,y) ((x) >= (y) ? (x) : (y))
#define MIN2(x,y) ((x) <= (y) ? (x) : (y))
#define MAX3(x,y,z) ((x) >= (y) && (x) >= (z) ? (x) : MAX2(y,z))
#define MIN3(x,y,z) ((x) <= (y) && (x) <= (z) ? (x) : MIN2(y,z))

#define SPACE_PENALITY -2

typedef enum {
    KeyboardTypeQwerty = 0,
    KeyboardTypeAzerty = 1
} KeyboardType;

int score2Letters (char a, char b);
int lettersIn(char a, char *all);
int** allocate2D(int rows,int cols);
void logMatrix(const char *seq1, const char *seq2, int lenSeq1, int lenSeq2, int** scoring);


int lettersAreProximalOnKeyboard(char a,char b, KeyboardType keyboard);
int lettersAreProximalOnQwertyKeyboard(char a,char b);
int lettersAreProximalOnAzertyKeyboard(char a,char b);

int score2Strings(const char *seq1, const char *seq2, int lenSeq1, int lenSeq2, int** scoring, int logEnable) {
    int i,j;
    int maxScore = 0;
    
    for(i = 0; i < lenSeq1; i++)
    {
        for(j = 0; j < lenSeq2; j++)
        {
            if(i == 0 && j ==0) {
                scoring[i][j] = score2Letters(seq1[i], seq2[j]);
            }
            else if(i == 0) {
                scoring[i][j] = MAX2(scoring[i][j-1] + SPACE_PENALITY,
                                     score2Letters(seq1[i], seq2[j]));
            }
            else if(j == 0) {
                scoring[i][j] = MAX2(scoring[i-1][j] + SPACE_PENALITY,
                                     score2Letters(seq1[i], seq2[j]));
            }
            else {
                scoring[i][j] = MAX3(scoring[i-1][j] + SPACE_PENALITY,
                                     scoring[i][j-1] + SPACE_PENALITY,
                                     scoring[i-1][j-1] + score2Letters(seq1[i], seq2[j]));
            }
            
            if (scoring[i][j] > maxScore) {
                maxScore = scoring[i][j];
            }
        }
        
        j = 0;
    }
    
    if (logEnable) {
        logMatrix(seq1,seq2,lenSeq1,lenSeq2,scoring);
    }
    
    return maxScore;
}

void logCalculatedMatrix(const char *seq1, const char *seq2, int lenSeq1, int lenSeq2)
{
    int max = MAX2(lenSeq1, lenSeq2);
    int **alignementMatrix = allocate2D(max,max);
    
    score2Strings(seq1, seq2, lenSeq1, lenSeq2,alignementMatrix,1);
    return;
}

void logMatrix(const char *seq1, const char *seq2, int lenSeq1, int lenSeq2, int** scoring) {
    int i,j;
    printf("\t");
    for (int i = 0; i < lenSeq2; i++) {
        printf("%c\t",seq2[i]);
    }
    printf("\n");

    for(i = 0; i < lenSeq1; i++)
    {
        printf("%c\t",seq1[i]);
        for(j = 0; j < lenSeq2; j++)
        {
            printf("%d\t",scoring[i][j]);
        }
        printf("\n");
    }
}

//allocate a 2D array
int** allocate2D(int rows,int cols)
{
    int **arr2D;
    int i;
    
    arr2D = (int**)malloc(rows*sizeof(int*));
    for(i=0;i<rows;i++)
    {
    	arr2D[i] = (int*)calloc(cols,sizeof(int));
    }
    
    return arr2D;
}


int score2Letters (char a, char b) {
    if (a == b) {
        return 2;
    }
    else if (abs(a - b) == 32) {
        return 2;
    }
    //Accent E
    if (lettersIn(a,"eéÈÉÊËèéêë") && lettersIn(b,"eéÈÉÊËèéêë")) {
        return 1;
    }
    
    //Accent A
    if (lettersIn(a,"aàáâ")&& lettersIn(b,"aàáâ")) {
        return 1;
    }
    
    return -2;
}

int lettersIn(char a, char *all) {
    int taille = (int)strlen(all);
    for (int i = 0; i < taille; i++) {
        if (all[i] == a) {
            return 1;
        }
    }
    
    return 0;
}

#warning TODO implement keyboard analysis
int lettersAreProximalOnKeyboard(char a,char b, KeyboardType keyboard) {
    switch (keyboard) {
        case KeyboardTypeQwerty:
            return lettersAreProximalOnQwertyKeyboard(a,b);
            break;
            
        case KeyboardTypeAzerty:
            return lettersAreProximalOnAzertyKeyboard(a,b);
            break;
            
        default:
            break;
    }
    return 0;
}

int lettersAreProximalOnQwertyKeyboard(char a,char b) {
    if (b == 'q') {
        if (lettersIn(a,"wa")){
            return 1;
        }
    }
    else if (b == 'w') {
        if (lettersIn(a,"qase")){
            return 1;
        }
    }
    else if (b == 'e') {
        if (lettersIn(a,"wsdr")){
            return 1;
        }
    }
    
    return 0;
}

int lettersAreProximalOnAzertyKeyboard(char a,char b) {
    
    return 0;
}
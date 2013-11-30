//
//  PermissiveAlignementMethods.h
//  PermissiveSearch
//
//  Created by Jerome Morissard on 10/26/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#ifndef FastScoring_AlignementMethods_h
#define FastScoring_AlignementMethods_h

int score2Strings(const char *seq1, const char *seq2, int lenSeq1, int lenSeq2, int** scoring, int logEnable);

void logCalculatedMatrix(const char *seq1, const char *seq2, int lenSeq1, int lenSeq2);

int** allocate2D(int rows,int cols);

#endif

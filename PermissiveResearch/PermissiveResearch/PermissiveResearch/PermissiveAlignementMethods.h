//
//  PermissiveAlignementMethods.h
//  PermissiveSearch
//
//  Created by Jerome Morissard on 10/26/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#ifndef AlignementMethods_h
#define AlignementMethods_h

struct PermissiveScoringMatrixStruct {
    int scorePerfectMatch;
    int scoreNotPerfectMatchKeyboardAnalyseHelp;
    int scoreNotPerfectBecauseOfAccents;
    int scoreLetterAddition;
};

typedef struct PermissiveScoringMatrixStruct     PermissiveScoringMatrixStruct;


int score2Strings(const char *seq1, const char *seq2, int lenSeq1, int lenSeq2, int** scoring, int logEnable, PermissiveScoringMatrixStruct scoringStructure);

void logCalculatedMatrix(const char *seq1, const char *seq2, int lenSeq1, int lenSeq2, PermissiveScoringMatrixStruct scoringStructure);

int** allocate2D(int rows,int cols);

#endif

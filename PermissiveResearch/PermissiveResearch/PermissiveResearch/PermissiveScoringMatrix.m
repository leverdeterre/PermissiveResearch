//
//  PermissiveScoringMatrix.m
//  PermissiveSearch
//
//  Created by Jerome Morissard on 11/9/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import "PermissiveScoringMatrix.h"
#import "PermissiveAlignementMethods.h"

void initWithDefaultValue(int** arr2D,int nbRows,int nbCols, int defaultValue);

@interface PermissiveScoringMatrix ()
@end

@implementation PermissiveScoringMatrix

+ (PermissiveScoringMatrix *)sharedScoringMatrix;
{
    static PermissiveScoringMatrix *scoringMatrix = nil;
    if (scoringMatrix == nil)
    {
        scoringMatrix = [[PermissiveScoringMatrix alloc] init];
        scoringMatrix.matrix = allocate2D(255, 255);
        initWithDefaultValue(scoringMatrix.matrix , 255, 255, -1);
    }
    
    return scoringMatrix;
}

@end

void initWithDefaultValue(int** arr2D,int nbRows,int nbCols, int defaultValue) {
    for(int i=0;i<nbRows;i++)
    {
        for(int j=0;j<nbCols;j++)
        {
            arr2D[i][j] = defaultValue;
            if (i == j) {
                arr2D[i][j] = 2;
            }
        }
    }
    
    //Accents lettre A
    arr2D[65][97] = 1;
    arr2D[65][131] = 1;
    arr2D[65][132] = 1;
    arr2D[65][133] = 1;
    
    arr2D[97][65] = 1;
    arr2D[97][131] = 1;
    arr2D[97][132] = 1;
    arr2D[97][133] = 1;
    
    arr2D[131][65] = 1;
    arr2D[131][97] = 1;
    arr2D[131][132] = 1;
    arr2D[131][133] = 1;
    
    arr2D[132][65] = 1;
    arr2D[132][97] = 1;
    arr2D[132][131] = 1;
    arr2D[132][133] = 1;
    
    arr2D[133][65] = 1;
    arr2D[133][97] = 1;
    arr2D[133][131] = 1;
    arr2D[133][132] = 1;
    
    
    //Accents lettre E
    arr2D[69][101] = 1;
    arr2D[69][130] = 1;
    arr2D[69][136] = 1;
    arr2D[69][137] = 1;
    arr2D[69][138] = 1;
    
    arr2D[101][69] = 1;
    arr2D[101][130] = 1;
    arr2D[101][136] = 1;
    arr2D[101][137] = 1;
    arr2D[101][138] = 1;
    
    arr2D[130][69] = 1;
    arr2D[130][101] = 1;
    arr2D[130][136] = 1;
    arr2D[130][137] = 1;
    arr2D[130][138] = 1;
    
    arr2D[136][69] = 1;
    arr2D[136][101] = 1;
    arr2D[136][130] = 1;
    arr2D[136][137] = 1;
    arr2D[136][138] = 1;
    
    arr2D[137][69] = 1;
    arr2D[137][101] = 1;
    arr2D[137][130] = 1;
    arr2D[137][136] = 1;
    arr2D[137][138] = 1;
    
    arr2D[138][69] = 1;
    arr2D[138][101] = 1;
    arr2D[138][130] = 1;
    arr2D[138][136] = 1;
    arr2D[138][137] = 1;
}

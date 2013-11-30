//
//  PermissiveScoringMatrix.h
//  PermissiveSearch
//
//  Created by Jerome Morissard on 11/9/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PermissiveScoringMatrix : NSObject

@property (assign, nonatomic) int** matrix;

+ (PermissiveScoringMatrix *)sharedScoringMatrix;

void initWithDefaultValue(int** arr2D,int nbRows,int nbCols, int defaultValue);

@end

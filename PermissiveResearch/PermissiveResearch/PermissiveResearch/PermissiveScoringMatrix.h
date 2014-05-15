//
//  PermissiveScoringMatrix.h
//  PermissiveSearch
//
//  Created by Jerome Morissard on 11/9/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PermissiveAlignementMethods.h"

typedef enum {
    ScoringEventPerfectMatch = 0,
    ScoringEventNotPerfectMatchKeyboardAnalyseHelp,
    ScoringEventNotPerfectBecauseOfAccents,
    ScoringEventLetterAddition
} ScoringEvent;

@interface PermissiveScoringMatrix : NSObject

@property (assign, nonatomic) NSInteger scorePerfectMatch;
@property (assign, nonatomic) NSInteger scoreNotPerfectMatchKeyboardAnalyseHelp;
@property (assign, nonatomic) NSInteger scoreNotPerfectBecauseOfAccents;
@property (assign, nonatomic) NSInteger scoreLetterAddition;
@property (assign, nonatomic) PermissiveScoringMatrixStruct structRepresentation;

+ (PermissiveScoringMatrix *)sharedScoringMatrix;
- (void)loadDefaultValues;
- (void)loadStructure;
- (NSInteger)defaultValuesForEvent:(ScoringEvent)event;

@end

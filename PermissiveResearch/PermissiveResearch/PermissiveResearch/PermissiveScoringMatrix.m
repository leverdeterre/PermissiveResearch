//
//  PermissiveScoringMatrix.m
//  PermissiveSearch
//
//  Created by Jerome Morissard on 11/9/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import "PermissiveScoringMatrix.h"

@interface PermissiveScoringMatrix ()
@end

@implementation PermissiveScoringMatrix

static PermissiveScoringMatrix *scoringMatrix = nil;

+ (PermissiveScoringMatrix *)sharedScoringMatrix;
{
    if (scoringMatrix == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
			scoringMatrix = [[self alloc] init];
        });
	}
    
    return scoringMatrix;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadDefaultValues];
        [self loadStructure];
    }
    
    return self;
}

#pragma mark -

- (void)loadDefaultValues
{
    _scorePerfectMatch = [self defaultValuesForEvent:ScoringEventPerfectMatch];
    _scoreNotPerfectMatchKeyboardAnalyseHelp = [self defaultValuesForEvent:ScoringEventNotPerfectMatchKeyboardAnalyseHelp];
    _scoreNotPerfectBecauseOfAccents = [self defaultValuesForEvent:ScoringEventNotPerfectBecauseOfAccents];
    _scoreLetterAddition = [self defaultValuesForEvent:ScoringEventLetterAddition];
}

- (void)loadStructure
{
    struct PermissiveScoringMatrixStruct maStructure;
    maStructure.scorePerfectMatch = (int)_scorePerfectMatch;
    maStructure.scoreNotPerfectBecauseOfAccents = (int)_scoreNotPerfectBecauseOfAccents;
    maStructure.scoreNotPerfectMatchKeyboardAnalyseHelp = (int)_scoreNotPerfectMatchKeyboardAnalyseHelp;
    maStructure.scoreLetterAddition = (int)_scoreLetterAddition;
    _structRepresentation = maStructure;
}

-(NSInteger)defaultValuesForEvent:(ScoringEvent)event
{
    switch (event) {
        case ScoringEventPerfectMatch:
            return 2;
            break;
            
        case ScoringEventNotPerfectMatchKeyboardAnalyseHelp:
            return 1;
            break;
            
        case ScoringEventNotPerfectBecauseOfAccents:
            return 2;
            break;
            
        case ScoringEventLetterAddition:
            return -2;
            break;
            
        default:
            break;
    }
    
    return NSNotFound;
}

@end
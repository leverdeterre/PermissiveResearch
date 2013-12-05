//
//  PermissiveOperations.h
//  PermissiveSearch
//
//  Created by Jerome Morissard on 10/29/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import <Foundation/Foundation.h>

// Log using the same parameters above but include the function name and source code line number in the log statement
#ifdef DEBUG
#define JMOLog(fmt, ...) NSLog((@"Func: %s, Line: %d, " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define JMOLog(...)
#endif

typedef void (^SearchCompletionBlock)(NSArray *findedElements);

typedef enum {
    ScoringOperationTypeExact,
    ScoringOperationTypeHeuristic,
    ScoringOperationTypeHeurexact
} ScoringOperationType;

///Align using scoring
@interface ScoringOperationQueue : NSOperationQueue

+ (ScoringOperationQueue *)mainQueue;

@end

@interface ExactScoringOperation : NSOperation

@property (strong, nonatomic) NSString *searchedString;
@property (nonatomic, copy) SearchCompletionBlock customCompletionBlock;

@end


///Alignement using fragments scoring
@interface HeuristicScoringOperation : ExactScoringOperation
@end

///Alignement using fragments scoring, then adjust with scoring
//Heurexact = Heuristic + Exact
@interface HeurexactScoringOperation : ExactScoringOperation

@end
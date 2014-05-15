//
//  JMOScoringOperation.m
//  PermissiveSearch
//
//  Created by Jerome Morissard on 10/29/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import "PermissiveOperations.h"
#import "PermissiveResearchDatabase.h"
#import "PermissiveAbstractObject.h"
#import "PermissiveAlignementMethods.h"
#import "PermissiveScoringMatrix.h"

@implementation ScoringOperationQueue

+ (ScoringOperationQueue *)mainQueue
{
    static ScoringOperationQueue *mainQueue = nil;
    if (mainQueue == nil)
    {
        mainQueue = [[ScoringOperationQueue alloc] init];
        mainQueue.maxConcurrentOperationCount = 1;
    }
    
    return mainQueue;
}

@end

@implementation ExactScoringOperation

#pragma mark -
#pragma mark - Main operation


- (BOOL)isConcurrent
{
    return NO;
}

- (void)main
{
    @autoreleasepool {
        
        int taille = (int)self.searchedString.length;
        int max = (int)MAX([[[PermissiveResearchDatabase sharedDatabase].elements valueForKeyPath:@"@max.flagLenght"] intValue], [self.searchedString length]);
        int **alignementMatrix = allocate2D(max,max);
        
        JMOLog(@"Searching %@ in %d elements", self.searchedString,(int)[PermissiveResearchDatabase sharedDatabase].elements.count);
        [[PermissiveResearchDatabase sharedDatabase].elements enumerateObjectsUsingBlock:^(PermissiveAbstractObject *obj, BOOL *stop) {
            if (self.isCancelled)
                return;
            obj.score = score2Strings(self.searchedString.UTF8String, obj.flag, taille, obj.flagLenght,alignementMatrix, 0, [PermissiveScoringMatrix sharedScoringMatrix].structRepresentation);
            
        }];
        
        if (self.isCancelled)
            return;
        
        JMOLog(@"Searching -> Done ");
        
        //Sorting
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
        NSArray *findedElements = [[[PermissiveResearchDatabase sharedDatabase].elements sortedArrayUsingDescriptors:@[sortDescriptor]] subarrayWithRange:NSMakeRange(0, 20)];
        
        //LOG MAX
        PermissiveAbstractObject *obj = [findedElements objectAtIndex:0];
        logCalculatedMatrix([self.searchedString UTF8String], obj.flag, (int)taille, obj.flagLenght, [PermissiveScoringMatrix sharedScoringMatrix].structRepresentation);
        
        if(self.customCompletionBlock) {
            self.customCompletionBlock(findedElements);
        }
    }
}


@end




@implementation HeuristicScoringOperation

#pragma mark -
#pragma mark - Main operation


- (BOOL)isConcurrent
{
    return NO;
}

- (void)main
{
    @autoreleasepool {
        
        if (self.searchedString.length < ScoringSegmentLenght) {
            if(self.customCompletionBlock) {
                JMOLog(@"Search operation aborded, search operation need more letters");
                self.customCompletionBlock(nil);
            }
            return;
        }
        
        JMOLog(@"Searching %@ in %d elements", self.searchedString,(int)[PermissiveResearchDatabase sharedDatabase].elements.count);
        [[PermissiveResearchDatabase sharedDatabase].elements enumerateObjectsUsingBlock:^(PermissiveAbstractObject *obj, BOOL *stop) {
            obj.score = 0;
        }];
        
        for (int i = 0; i <= self.searchedString.length - ScoringSegmentLenght; i++) {
            NSString *segment = [self.searchedString substringWithRange:NSMakeRange(i, ScoringSegmentLenght)];
            [[[PermissiveResearchDatabase sharedDatabase] objectsForSegment:segment] enumerateObjectsUsingBlock:^(PermissiveAbstractObject *obj, BOOL *stop) {
                obj.score++;
            }];
        }
        
        if (self.isCancelled)
            return;
        
        JMOLog(@"Searching -> Done ");
    
        //Sorting
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
        NSArray *findedElements = [[[PermissiveResearchDatabase sharedDatabase].elements sortedArrayUsingDescriptors:@[sortDescriptor]] subarrayWithRange:NSMakeRange(0, 20)];
        

        //LOG MAX
        NSUInteger taille = self.searchedString.length;
        PermissiveAbstractObject *obj = [findedElements objectAtIndex:0];
        logCalculatedMatrix([self.searchedString UTF8String], obj.flag, (int)taille, obj.flagLenght, [PermissiveScoringMatrix sharedScoringMatrix].structRepresentation);
        
        if(self.customCompletionBlock) {
            self.customCompletionBlock(findedElements);
        }
    }
}
@end



@implementation HeurexactScoringOperation

#pragma mark -
#pragma mark - Main operation


- (BOOL)isConcurrent
{
    return NO;
}

- (void)main
{
    @autoreleasepool {
        
        if (self.searchedString.length < ScoringSegmentLenght) {
            if(self.customCompletionBlock) {
                self.customCompletionBlock(nil);
            }
            return;
        }
        
        JMOLog(@"Searching %@ in %d elements", self.searchedString,(int)[PermissiveResearchDatabase sharedDatabase].elements.count);
        [[PermissiveResearchDatabase sharedDatabase].elements enumerateObjectsUsingBlock:^(PermissiveAbstractObject *obj, BOOL *stop) {
            obj.score = 0;
        }];
        
        for (int i = 0; i < self.searchedString.length - ScoringSegmentLenght; i++) {
            NSString *segment = [self.searchedString substringWithRange:NSMakeRange(i, ScoringSegmentLenght)];
            [[[PermissiveResearchDatabase sharedDatabase] objectsForSegment:segment] enumerateObjectsUsingBlock:^(PermissiveAbstractObject *obj, BOOL *stop) {
                obj.score++;
            }];
        }
        
        if (self.isCancelled)
            return;
        
        JMOLog(@"Searching -> Done ");
        
        
        JMOLog(@"Start adjusting -> Done ");
        //Sorting
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
        NSArray *arrayOfElemets = [[PermissiveResearchDatabase sharedDatabase].elements sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        int taille = (int)self.searchedString.length;
        int max = (int)MAX([[[PermissiveResearchDatabase sharedDatabase].elements valueForKeyPath:@"@max.flagLenght"] intValue], [self.searchedString length]);
        int **alignementMatrix = allocate2D(max,max);
        
        [arrayOfElemets enumerateObjectsUsingBlock:^(PermissiveAbstractObject *obj, NSUInteger idx, BOOL *stop) {
            if (self.isCancelled)
                return;
            
            if (idx == 50) {
                *stop = YES;
            }
            
            obj.score = score2Strings(self.searchedString.UTF8String, obj.flag, taille, obj.flagLenght,alignementMatrix, 0,[PermissiveScoringMatrix sharedScoringMatrix].structRepresentation);
            
        }];
        
        NSArray *findedElements = [[arrayOfElemets sortedArrayUsingDescriptors:@[sortDescriptor]] subarrayWithRange:NSMakeRange(0, 20)];
        
        //LOG MAX
        PermissiveAbstractObject *obj = [findedElements objectAtIndex:0];
        logCalculatedMatrix([self.searchedString UTF8String], obj.flag, (int)taille, obj.flagLenght, [PermissiveScoringMatrix sharedScoringMatrix].structRepresentation);
        
        if(self.customCompletionBlock) {
            self.customCompletionBlock(findedElements);
        }
    }
}

@end


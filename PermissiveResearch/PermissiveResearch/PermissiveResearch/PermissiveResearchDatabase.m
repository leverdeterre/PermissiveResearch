//
//  ScoringDatabase.m
//  PermissiveSearch
//
//  Created by Jerome Morissard on 11/8/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import "PermissiveResearchDatabase.h"
#import "PermissiveOperations.h"
#import "PermissiveAbstractObject.h"
#import "PermissiveObjects.h"

@interface PermissiveResearchDatabase ()
@property (strong, nonatomic) NSMutableDictionary *segments;  //NSDictionary of NSSet
@end

@implementation PermissiveResearchDatabase

static PermissiveResearchDatabase *mainDatabase = nil;

+ (instancetype)sharedDatabase
{
    if (mainDatabase == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
			mainDatabase = [[self alloc] init];
        });
	}
    
    return mainDatabase;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        _elements = [NSMutableSet new];
        _segments = [NSMutableDictionary new];
        [_datasource rebuildDatabase];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    JMOLog(@"didReceiveMemoryWarning");
    //Doint something ? if nos search operations in progress will could release all retained objects
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
}

#pragma mark - Overide Setter

- (void)setDatasource:(id<PermissiveResearchDatasource>)datasource
{
    _datasource = datasource;
    [_datasource rebuildDatabase];
    [self rebuildScoringMatrix];
}

- (void)rebuildScoringMatrix
{
    PermissiveScoringMatrix *scoringMatrix = [PermissiveScoringMatrix sharedScoringMatrix];
    
    if ([self.datasource respondsToSelector:@selector(customCostForEvent:)])
    {
        //ScoringEventPerfectMatch
        NSInteger customValue = [self.datasource customCostForEvent:ScoringEventPerfectMatch];
        if (customValue != NSNotFound) {
            [scoringMatrix setScorePerfectMatch:customValue];
        }
        else {
            [scoringMatrix setScorePerfectMatch:[scoringMatrix defaultValuesForEvent:ScoringEventPerfectMatch]];
        }
        
        //ScoringEventNotPerfectMatchKeyboardAnalyseHelp
        customValue = [self.datasource customCostForEvent:ScoringEventNotPerfectMatchKeyboardAnalyseHelp];
        if (customValue != NSNotFound) {
            [[PermissiveScoringMatrix sharedScoringMatrix] setScoreNotPerfectMatchKeyboardAnalyseHelp:customValue];
        }
        else {
            [scoringMatrix setScorePerfectMatch:[scoringMatrix defaultValuesForEvent:ScoringEventNotPerfectMatchKeyboardAnalyseHelp]];
        }
        
        //ScoringEventNotPerfectBecauseOfAccents
        customValue = [self.datasource customCostForEvent:ScoringEventNotPerfectBecauseOfAccents];
        if (customValue != NSNotFound) {
            [[PermissiveScoringMatrix sharedScoringMatrix] setScoreNotPerfectBecauseOfAccents:customValue];
        }
        else {
            [scoringMatrix setScorePerfectMatch:[scoringMatrix defaultValuesForEvent:ScoringEventNotPerfectBecauseOfAccents]];
        }
        
        //ScoringEventLetterAddition
        customValue = [self.datasource customCostForEvent:ScoringEventLetterAddition];
        if (customValue != NSNotFound) {
            [[PermissiveScoringMatrix sharedScoringMatrix] setScoreLetterAddition:customValue];
        }
        else {
            [scoringMatrix setScorePerfectMatch:[scoringMatrix defaultValuesForEvent:ScoringEventLetterAddition]];
        }
    }
    else {
        [[PermissiveScoringMatrix sharedScoringMatrix]  loadDefaultValues];
    }
    
    [scoringMatrix loadStructure];
}

#pragma mark - Add objects

- (void)addObject:(id)obj forKey:(NSString *)key
{
    PermissiveObject *scoringObj = [PermissiveObject new];
    scoringObj.refencedObject = obj;
    scoringObj.flag = strdup([key UTF8String]);  //duplicate char* to be not constant
    scoringObj.flagLenght = key.length;
    [self.elements addObject:scoringObj];
    
    [self addSegmentsForKey:key forObject:scoringObj];
}

- (void)addObjects:(NSArray *)objs forKey:(NSString *)key
{
    [objs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addObject:obj forKey:key];
    }];
}

- (void)addObjects:(NSArray *)objs forKeys:(NSArray *)keys
{
    [objs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [keys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
            [self addObject:obj forKey:key];
        }];
    }];
}

- (void)addObjects:(NSArray *)objs forKeyPaths:(NSArray *)KeyPaths
{
    [objs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [KeyPaths enumerateObjectsUsingBlock:^(id keyPath, NSUInteger idx, BOOL *stop) {
            [self addObject:obj forKey:[obj valueForKey:keyPath]];
        }];
    }];
}

#pragma mark - Add CoreData objects

- (void)addManagedObject:(NSManagedObject *)obj forKey:(NSString *)key
{
    [self addManagedObject:obj forKey:key isAlreadQueueProtected:NO];
}

- (void)addManagedObjects:(NSArray *)objs forKey:(NSString *)key
{
    NSArray *contexts = [objs valueForKeyPath:@"@distinctUnionOfObjects.managedObjectContext"];
    NSAssert(contexts.count < 1, @"What? multiple managedObjectContext");
    
    NSManagedObjectContext *firstContext = [contexts firstObject];

    //Need to check concurrency type?
    [firstContext performBlockAndWait:^{
        [objs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self addManagedObject:obj forKey:key isAlreadQueueProtected:YES];
        }];
    }];
}

- (void)addManagedObject:(NSManagedObject *)obj forKey:(NSString *)key isAlreadQueueProtected:(BOOL)isAlreadQueueProtected
{
    if (NO == isAlreadQueueProtected) {
        [obj.managedObjectContext performBlockAndWait:^{
            [self addManagedObject:obj forKey:key isAlreadQueueProtected:YES];
        }];
        return;
    } else {
        PermissiveCoreDataObject *scoringObj = [PermissiveCoreDataObject new];
        scoringObj.flag = strdup([[obj valueForKey:key] UTF8String]);  //duplicate char* to be not constant
        scoringObj.flagLenght = key.length;
        scoringObj.objectID = [obj objectID];
        [self.elements addObject:scoringObj];
        
        [self addSegmentsForKey:key forObject:scoringObj];
    }
}

- (void)addManagedObjects:(NSArray *)objs forKeys:(NSArray *)keys
{
    NSArray *contexts = [objs valueForKeyPath:@"@distinctUnionOfObjects.managedObjectContext"];
    NSAssert(contexts.count < 1, @"What? multiple managedObjectContext");
    
    NSManagedObjectContext *firstContext = [contexts firstObject];
    //Need to check concurrency type?
    [firstContext performBlockAndWait:^{
        [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [objs enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
                [self addManagedObject:obj forKey:key isAlreadQueueProtected:YES];
            }];
        }];
    }];
}

- (void)addManagedObjects:(NSArray *)objs forKeyPaths:(NSArray *)keyPaths
{
    NSArray *contexts = [objs valueForKeyPath:@"@distinctUnionOfObjects.managedObjectContext"];
    NSAssert(contexts.count < 1, @"What? multiple managedObjectContext");
    
    NSManagedObjectContext *firstContext = [contexts firstObject];
    //Need to check concurrency type?
    [firstContext performBlockAndWait:^{
        [objs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [keyPaths enumerateObjectsUsingBlock:^(id keyPath, NSUInteger idx, BOOL *stop) {
                [self addManagedObject:obj forKey:[obj valueForKey:keyPath] isAlreadQueueProtected:YES];
            }];
        }];
    }];
}


#pragma mark - Add segments

- (void)addSegmentsForKey:(NSString *)key forObject:(id)obj
{
    //NSAssert(key.length>ScoringSegmentLenght, @"key.length>ScoringSegmentLenght");
    if (key.length < ScoringSegmentLenght) {
        [self addSegment:key forObject:obj];
        return;
    }
    
    for (int i = 0; i < key.length - ScoringSegmentLenght; i++) {
        NSString *segment = [key substringWithRange:NSMakeRange(i, ScoringSegmentLenght)];
        [self addSegment:segment forObject:obj];
    }
}

- (void)addSegment:(NSString *)segment forObject:(id)obj
{
    NSMutableSet *set = [self.segments objectForKey:[segment lowercaseString]];
    if (nil == set) {
        set = [NSMutableSet new];
        [self.segments setObject:set forKey:[segment lowercaseString]];
    }
    
    [set addObject:obj];
}

- (NSMutableSet *)objectsForSegment:(NSString *)key
{
    return [self.segments objectForKey:[key lowercaseString]];
}

#pragma mark - Search methods

- (void)searchString:(NSString *)searchedString withOperation:(ScoringOperationType)operationType
{
    [[ScoringOperationQueue mainQueue] cancelAllOperations];

    ExactScoringOperation *operation;
    if (operationType == ScoringOperationTypeExact) {
        operation = [ExactScoringOperation new];
    }
    else if (operationType == ScoringOperationTypeHeuristic) {
        operation = [HeuristicScoringOperation new];
    }
    else if (operationType == ScoringOperationTypeHeurexact) {
        operation = [HeurexactScoringOperation new];
    }
    
    operation.searchedString = searchedString;
    SearchCompletionBlock block = ^(NSArray *results) {
        if ([self.delegate respondsToSelector:@selector(searchCompletedWithResults:)]) {
            [self.delegate searchCompletedWithResults:results];
        }
    };
    
    [operation setCustomCompletionBlock:block];
    [[ScoringOperationQueue mainQueue] addOperation:operation];
}

@end

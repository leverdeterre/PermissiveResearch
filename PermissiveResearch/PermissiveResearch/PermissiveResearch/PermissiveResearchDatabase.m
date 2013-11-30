//
//  ScoringDatabase.m
//  PermissiveSearch
//
//  Created by Jerome Morissard on 11/8/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import "PermissiveResearchDatabase.h"
#import "PermissiveOperations.h"
#import "PermissiveObject.h"
#import <CoreData/CoreData.h>

@interface PermissiveResearchDatabase ()
@property (strong, nonatomic) NSMutableDictionary *segments;  //NSDictionary of NSSet
@end

@implementation PermissiveResearchDatabase

+ (PermissiveResearchDatabase *)sharedDatabase
{
    static PermissiveResearchDatabase *mainDatabase = nil;
    if (mainDatabase == nil)
    {
        mainDatabase = [[PermissiveResearchDatabase alloc] init];
        mainDatabase.elements = [NSMutableSet new];
        mainDatabase.segments = [NSMutableDictionary new];
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
}

#pragma mark -

- (void)addRetainedObjet:(id)obj forKey:(NSString *)key
{
    PermissiveObject *scoringObj = [PermissiveObject new];
    scoringObj.refencedObject = obj;
    scoringObj.key = strdup([key UTF8String]);  //duplicate char* to be not constant
    scoringObj.keyLenght = key.length;
    scoringObj.scoringObjectType = ScoringObjectTypeClassic;
    [self.elements addObject:scoringObj];
    
    [self addSegmentsForKey:key forObject:scoringObj];
}

- (void)addManagedObjet:(NSManagedObject *)obj forKey:(NSString *)key
{
    PermissiveObject *scoringObj = [PermissiveObject new];
    scoringObj.key = strdup([key UTF8String]);  //duplicate char* to be not constant
    scoringObj.keyLenght = key.length;
    scoringObj.scoringObjectType = ScoringObjectTypeCoreData;
    scoringObj.refencedObject = [obj objectID];
    [self.elements addObject:scoringObj];
    
    [self addSegmentsForKey:key forObject:scoringObj];
}

- (void)addSegmentsForKey:(NSString *)key forObject:(id)obj
{
    //NSAssert(key.length>ScoringSegmentLenght, @"key.length>ScoringSegmentLenght");
    if (key.length<ScoringSegmentLenght) {
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


@end

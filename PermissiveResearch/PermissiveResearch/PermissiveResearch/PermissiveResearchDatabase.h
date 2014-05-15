//
//  ScoringDatabase.h
//  PermissiveSearch
//
//  Created by Jerome Morissard on 11/8/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "PermissiveResearch.h"

#define ScoringSegmentLenght 3

@interface PermissiveResearchDatabase : NSObject

@property (strong, atomic) NSMutableSet *elements;
@property (weak, nonatomic) id <PermissiveResearchDatasource> datasource;
@property (weak, nonatomic) id <PermissiveResearchDelegate> delegate;

+ (PermissiveResearchDatabase *)sharedDatabase;

- (void)addObject:(id)obj forKey:(NSString *)key;
- (void)addObjects:(NSArray *)obj forKey:(NSString *)key;
- (void)addObjects:(NSArray *)objs forKeys:(NSArray *)keys;
- (void)addObjects:(NSArray *)objs forKeyPaths:(NSArray *)KeyPaths;

- (void)addManagedObject:(NSManagedObject *)obj forKey:(NSString *)key;
- (void)addManagedObjects:(NSArray *)objs forKey:(NSString *)key;
- (void)addManagedObjects:(NSArray *)objs forKeys:(NSArray *)keys;
- (void)addManagedObjects:(NSArray *)objs forKeyPaths:(NSArray *)KeyPaths;

- (NSMutableSet *)objectsForSegment:(NSString *)key;
- (void)searchString:(NSString *)searchedString withOperation:(ScoringOperationType)operationType;

@end

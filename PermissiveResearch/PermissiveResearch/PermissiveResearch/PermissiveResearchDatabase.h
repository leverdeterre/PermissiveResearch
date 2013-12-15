//
//  ScoringDatabase.h
//  PermissiveSearch
//
//  Created by Jerome Morissard on 11/8/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PermissiveOperations.h"
#import "PermissiveScoringMatrix.h"

#define ScoringSegmentLenght 3

@protocol PermissiveResearchDatasource <NSObject>
@required
-(void)rebuildDatabase;

@optional
-(NSInteger)customCostForEvent:(ScoringEvent)event;
@end

@protocol PermissiveResearchDelegate <NSObject>
@required
-(void)searchCompletedWithResults:(NSArray *)results;
@end

@interface PermissiveResearchDatabase : NSObject

@property (strong, atomic) NSMutableSet *elements;
@property (weak, nonatomic) id <PermissiveResearchDatasource> datasource;
@property (weak, nonatomic) id <PermissiveResearchDelegate> delegate;

+ (PermissiveResearchDatabase *)sharedDatabase;

- (void)addRetainedObjet:(id)obj forKey:(NSString *)key;
- (void)addManagedObjet:(id)obj forKey:(NSString *)key;
- (NSMutableSet *)objectsForSegment:(NSString *)key;
- (void)searchString:(NSString *)searchedString withOperation:(ScoringOperationType)operationType;

@end

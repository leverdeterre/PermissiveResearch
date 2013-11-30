//
//  ScoringDatabase.h
//  PermissiveSearch
//
//  Created by Jerome Morissard on 11/8/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ScoringSegmentLenght 3

@protocol PermissiveResearchDatasource <NSObject>
@required
-(void)reloadData;
@end

@interface PermissiveResearchDatabase : NSObject

@property (strong, atomic) NSMutableSet *elements;
@property (weak, nonatomic) id <PermissiveResearchDatasource> datasource;

+ (PermissiveResearchDatabase *)sharedDatabase;

- (void)addRetainedObjet:(id)obj forKey:(NSString *)key;
- (void)addManagedObjet:(id)obj forKey:(NSString *)key;
- (NSMutableSet *)objectsForSegment:(NSString *)key;

@end

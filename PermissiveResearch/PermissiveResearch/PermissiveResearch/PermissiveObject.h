//
//  PermissiveObject.h
//  PermissiveSearch
//
//  Created by Jerome Morissard on 10/26/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    ScoringObjectTypeClassic,
    ScoringObjectTypeCoreData
} ScoringObjectType;


@interface PermissiveObject : NSObject

@property (assign, nonatomic) char *key;
@property (assign, nonatomic) short keyLenght;
@property (assign, nonatomic) short score;

@property (strong, nonatomic) id refencedObject;
@property (assign, nonatomic) NSManagedObjectID *objectID; //CoreData
@property (assign, nonatomic) ScoringObjectType scoringObjectType;
@end

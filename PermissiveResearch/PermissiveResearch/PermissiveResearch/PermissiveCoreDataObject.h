//
//  PermissiveCoreDataObject.h
//  PermissiveResearch
//
//  Created by Jerome Morissard on 5/15/14.
//  Copyright (c) 2014 Jerome Morissard. All rights reserved.
//

#import "PermissiveAbstractObject.h"

@interface PermissiveCoreDataObject : PermissiveAbstractObject

@property (strong, nonatomic) NSManagedObjectID *objectID;

@end

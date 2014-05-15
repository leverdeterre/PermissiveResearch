//
//  PermissiveResearchDatasource.h
//  PermissiveResearch
//
//  Created by Jerome Morissard on 5/15/14.
//  Copyright (c) 2014 Jerome Morissard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PermissiveScoringMatrix.h"

@protocol PermissiveResearchDatasource <NSObject>

- (void)rebuildDatabase;

@optional
- (NSInteger)customCostForEvent:(ScoringEvent)event;

@end

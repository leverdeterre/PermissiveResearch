//
//  PermissiveResearchDelegate.h
//  PermissiveResearch
//
//  Created by Jerome Morissard on 5/15/14.
//  Copyright (c) 2014 Jerome Morissard. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PermissiveResearchDelegate <NSObject>

-(void)searchCompletedWithResults:(NSArray *)results;

@end

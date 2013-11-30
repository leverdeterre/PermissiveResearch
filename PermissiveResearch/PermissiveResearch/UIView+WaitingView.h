//
//  UIView+WaitingView.h
//
//  Created by Jerome Morissard on 11/8/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * @ingroup categories
 */
@interface UIView (WaitingView)
/**
 *  Add a Waiting View on self 
 */
-(void) addWaitingView;

/**
 *  Add a custom Waiting View on self
 */
-(void) addCustomWaitingView:(UIView*)waitingView;

/**
 *  Remove the WaitingView
 */
-(void) removeWaitingView;

-(BOOL) isWaiting;

@end

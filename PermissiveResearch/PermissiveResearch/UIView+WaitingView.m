//
//  UIView+WaitingView.m
//
//  Created by Jerome Morissard on 11/8/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import "UIView+WaitingView.h"

#import <objc/runtime.h>


@implementation UIView (BkExtensions)

const char * const WaitingViewKey = "waiting.view";

-(void) addWaitingView
{
    UIView *waitingView = (UIView *) objc_getAssociatedObject(self, WaitingViewKey);
    if(nil == waitingView){
        waitingView = [[UIView alloc] initWithFrame:self.bounds];
        waitingView.backgroundColor = [UIColor blackColor];
        waitingView.alpha = 0.30;
        
        
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        activity.center = waitingView.center;
        activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [waitingView addSubview:activity];
        [activity startAnimating];
        
        objc_setAssociatedObject(self, WaitingViewKey, waitingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self addSubview:waitingView];
    }
}

-(void) addCustomWaitingView:(UIView*)waitingViewCustom;
{
    UIView *waitingView = (UIView *) objc_getAssociatedObject(self, WaitingViewKey);
    if(nil != waitingView){
        [self removeWaitingView];
    }
    waitingView = waitingViewCustom;
    objc_setAssociatedObject(self, WaitingViewKey, waitingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addSubview:waitingView];
}


-(void) removeWaitingView
{
    UIView *waitingView = (UIView *) objc_getAssociatedObject(self, WaitingViewKey);
    if(nil != waitingView){
        [waitingView removeFromSuperview];
        objc_setAssociatedObject(self, WaitingViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

-(BOOL)isWaiting
{
    UIView *waitingView = (UIView *) objc_getAssociatedObject(self, WaitingViewKey);
    if(waitingView){
        return YES;
    }
    return NO;
}


@end

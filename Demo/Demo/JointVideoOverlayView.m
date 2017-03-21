//
//  JointVideoOverlayView.m
//  Demo
//
//  Created by Tony on 2017/3/21.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "JointVideoOverlayView.h"

@implementation JointVideoOverlayView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    BOOL containerFlag = [self.containerView pointInside:[self convertPoint:point toView:self.containerView] withEvent:event];
    
    if (containerFlag) {
        return YES;
    }
    
    return NO;
}

@end

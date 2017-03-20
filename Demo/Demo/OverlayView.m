//
//  OverlayView.m
//  Demo
//
//  Created by Tony on 2017/3/20.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "OverlayView.h"

@implementation OverlayView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self.captureButton pointInside:[self convertPoint:point toView:self.captureButton] withEvent:event]) {
        return YES;
    }
    
    return NO;
}

@end

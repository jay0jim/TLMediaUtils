//
//  OverlayView.m
//  Demo
//
//  Created by Tony on 2017/3/20.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "OverlayView.h"

@implementation OverlayView

// 这个方法就是用来实现除了点击按钮外，其他地方穿透到下面的previewView中
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL captureButtonFlag = [self.captureButton pointInside:[self convertPoint:point toView:self.captureButton] withEvent:event];
    
    BOOL switchCamButtonFlag = [self.switchCamButton pointInside:[self convertPoint:point toView:self.switchCamButton] withEvent:event];
    
    if (captureButtonFlag || switchCamButtonFlag) {
        return YES;
    }
    
    return NO;
}

@end

//
//  TLPreviewView.h
//  TLMediaUtils
//
//  Created by Tony on 2017/3/20.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

@class TLPreviewView;

@protocol TLPreviewViewDelegate <NSObject>

- (void)previewView:(TLPreviewView *)previewView focusAtPoint:(CGPoint)point;
- (void)previewView:(TLPreviewView *)previewView exposeAtPoint:(CGPoint)point;

@end

@interface TLPreviewView : UIView

@property (strong, nonatomic) AVCaptureSession *session;
@property (weak, nonatomic) id<TLPreviewViewDelegate> delegate;

@property (assign, nonatomic) BOOL tapToFocusEnable;
@property (assign, nonatomic) BOOL tapToExposeEnable;

@end

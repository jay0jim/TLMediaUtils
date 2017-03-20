//
//  TLPreviewView.m
//  TLMediaUtils
//
//  Created by Tony on 2017/3/20.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "TLPreviewView.h"

@interface TLPreviewView ()

@property (assign, nonatomic) CGPoint focusPoint;

@end

@implementation TLPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self setupViews];
        
    }
    return self;
}

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (void)setupViews {
    
    ((AVCaptureVideoPreviewLayer *)self.layer).videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)setSession:(AVCaptureSession *)session {
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
}

- (AVCaptureSession *)session {
    return [(AVCaptureVideoPreviewLayer *)self.layer session];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    
    self.focusPoint = [recognizer locationInView:self];
    
    // 将屏幕上的点转化为摄像头坐标系中的点
    CGPoint pointOfInterest = [self convertToPointOfInterestFromPoint:self.focusPoint];
    
#warning TODO - 添加动画框框
    
    if (self.delegate) {
        [self.delegate previewView:self focusAtPoint:pointOfInterest];
        [self.delegate previewView:self exposeAtPoint:pointOfInterest];
    }
}

- (CGPoint)convertToPointOfInterestFromPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    return [layer captureDevicePointOfInterestForPoint:point];
}

- (void)drawFocusBox {
    UIBezierPath *path = [UIBezierPath bezierPath];
}

@end



















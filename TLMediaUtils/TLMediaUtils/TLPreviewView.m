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
@property (strong, nonatomic) UIView *boxView;

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
    
    self.boxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    self.boxView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.boxView];
    
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
    
    if (self.tapToFocusEnable || self.tapToExposeEnable) {
        [self drawFocusBoxWithPoint:self.focusPoint];
    }
    if (self.tapToFocusEnable) {
        if (self.delegate) {
            [self.delegate previewView:self focusAtPoint:pointOfInterest];
        }
    }
    if (self.tapToExposeEnable) {
        if (self.delegate) {
            [self.delegate previewView:self exposeAtPoint:pointOfInterest];
        }
    }
}

- (CGPoint)convertToPointOfInterestFromPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    return [layer captureDevicePointOfInterestForPoint:point];
}

- (void)drawFocusBoxWithPoint:(CGPoint)point {
    
    self.boxView.center = point;
    self.boxView.layer.borderWidth = 1;
    self.boxView.layer.borderColor = [UIColor yellowColor].CGColor;
    
    // for animation
    self.boxView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    self.boxView.alpha = 1.0f;
    
    NSInteger flag = arc4random();
    self.boxView.tag = flag;
    
    [self addSubview:self.boxView];
    
    [UIView animateWithDuration:0.2 animations:^{
        //
        self.boxView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        //
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.boxView.tag == flag) {
                self.boxView.alpha = 0.5f;
            } else {
                return ;
            }
        });
    }];
    
}

@end



















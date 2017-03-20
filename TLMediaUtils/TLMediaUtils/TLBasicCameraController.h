//
//  TLBasicCameraController.h
//  TLMediaUtils
//
//  Created by Tony on 2017/3/20.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

@interface TLBasicCameraController : NSObject

/**
 用于管理输入输出设备
 */
@property (strong, nonatomic) AVCaptureSession *captureSession;

// session
- (BOOL)setupSession:(NSError **)error;
- (void)startSession;
- (void)stopSession;

// capture
- (void)captureStillImage;

@end

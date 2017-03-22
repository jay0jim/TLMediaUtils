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

@property (assign, nonatomic, readonly) BOOL isCapturingVideo;

/**
 * 设置图片保存的沙盒路径，如果设置为nil，则表示不保存到沙盒
 */
@property (strong, nonatomic) NSURL *outputImageURL;

/**
 * 设置视频保存的沙盒路径，如果设置为nil，则表示不另外保存到沙盒，只保留临时文件
 */
@property (strong, nonatomic) NSURL *outputVideoURL;

@property (assign, nonatomic) BOOL isSaveImageToLibrary;
@property (assign, nonatomic) BOOL isSaveVideoToLibrary;

// session
- (BOOL)setupSession:(NSError **)error;
- (void)startSession;
- (void)stopSession;

// capture still image
- (void)captureStillImage;

// capture video
- (void)startCaptureVideo;
- (void)stopCaptureVideo;

// focus and expose
- (BOOL)canFocusAtPoint;
- (BOOL)canExposeAtPoint;
- (void)focusAtPoint:(CGPoint)point;
- (void)exposeAtPoint:(CGPoint)point;

// switch camera
- (BOOL)isSwitchCameraSupported;
- (void)switchCamera;

@end












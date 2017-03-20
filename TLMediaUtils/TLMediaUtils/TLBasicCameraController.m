//
//  TLBasicCameraController.m
//  TLMediaUtils
//
//  Created by Tony on 2017/3/20.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "TLBasicCameraController.h"

@interface TLBasicCameraController ()

/**
 * 使用中的device input，更换前后摄像头（如果有）需要用到
 */
@property (strong, nonatomic) AVCaptureDeviceInput *currentInput;

/**
 * 输出静态图片，即拍照
 */
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

/**
 * 输出视频 文件
 */
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieOutput;

/**
 * session队列（串行）
 */
@property (strong, nonatomic) dispatch_queue_t sessionQueue;


@end

@implementation TLBasicCameraController

- (BOOL)setupSession:(NSError *__autoreleasing *)error {
    
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    // 视频输入
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.currentInput = videoInput;
        } else {
            return NO;
        }
    }
    
    // 音频输入
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if (audioInput) {
        if ([self.captureSession canAddInput:audioInput]) {
            [self.captureSession addInput:audioInput];
        } else {
            return NO;
        }
    }
    
    // 图片输出
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.stillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
    if ([self.captureSession canAddOutput:self.stillImageOutput]) {
        [self.captureSession addOutput:self.stillImageOutput];
    }
    
    // 视频文件输出
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    }
    
    // 串行队列
    self.sessionQueue = dispatch_queue_create("sessionQueue", NULL);
    
    return YES;
}

- (void)startSession {
    if (!self.captureSession.isRunning) {
        dispatch_async(self.sessionQueue, ^{
            [self.captureSession startRunning];
        });
    }
}

- (void)stopSession {
    if (self.captureSession.isRunning) {
        dispatch_async(self.sessionQueue, ^{
            [self.captureSession stopRunning];
        });
    }
}

@end

















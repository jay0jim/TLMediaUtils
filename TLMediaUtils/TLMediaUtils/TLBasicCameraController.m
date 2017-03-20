//
//  TLBasicCameraController.m
//  TLMediaUtils
//
//  Created by Tony on 2017/3/20.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "TLBasicCameraController.h"
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreMotion/CoreMotion.h>

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

/**
 * CoreMotion: 用于检测设备方向（无论用户是否开启屏幕旋转功能）
 */
@property (strong, nonatomic) CMMotionManager *motionManager;

/**
 * MotionManager所在的queue
 */
@property (strong, nonatomic) NSOperationQueue *motionQueue;
@property (assign, nonatomic) AVCaptureVideoOrientation deviceOrientation;

@end

@implementation TLBasicCameraController

- (instancetype)init {
    if (self = [super init]) {
        
        [self setupMotionManager];
        
    }
    return self;
}

#pragma mark - Session
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

#pragma mark - Capture Still Image
- (void)captureStillImage {
    AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if ([connection isVideoOrientationSupported]) {
        connection.videoOrientation = self.deviceOrientation;
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        if (imageDataSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            
            UIImage *image = [UIImage imageWithData:imageData];
            [self writeImageToAssetsLibrary:image];
        }
    }];
}

- (void)writeImageToAssetsLibrary:(UIImage *)image {
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    [assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:(NSUInteger)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error) {
            // TODO: to be completed
        } else {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

#pragma mark - CoreMotion Orientation
- (void)setupMotionManager {
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 0.5;
    
    self.motionQueue = [[NSOperationQueue alloc] init];
    
    if (self.motionManager.deviceMotionAvailable) {
        [self.motionManager startDeviceMotionUpdatesToQueue:self.motionQueue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            
            self.deviceOrientation = [self currentVideoOrientationWithDeviceMotion:motion];
        }];
    }
    
}

- (AVCaptureVideoOrientation)currentVideoOrientationWithDeviceMotion:(CMDeviceMotion *)motion {
    AVCaptureVideoOrientation orientation;
    
    double x = motion.gravity.x;
    double y = motion.gravity.y;
    if (fabs(y) >= fabs(x))
    {
        if (y >= 0){
            // UIDeviceOrientationPortraitUpsideDown;
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
        }
        else{
            // UIDeviceOrientationPortrait;
            orientation = AVCaptureVideoOrientationPortrait;
        }
    }
    else
    {
        if (x >= 0){
            // UIDeviceOrientationLandscapeRight;
            orientation = AVCaptureVideoOrientationLandscapeLeft;
        }
        else{
            // UIDeviceOrientationLandscapeLeft;
            orientation = AVCaptureVideoOrientationLandscapeRight;
        }
    }
    
    return orientation;
}


#pragma mark - dealloc
- (void)dealloc {
    [self.motionManager stopDeviceMotionUpdates];
}

@end

















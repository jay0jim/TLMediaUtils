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

NSString *TLFinishSavingImageNotification = @"ImageSavingDone";
NSString *TLFinishSavingVideoNotification = @"VideoSavingDone";

@interface TLBasicCameraController () <AVCaptureFileOutputRecordingDelegate>

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
            [[NSNotificationCenter defaultCenter] postNotificationName:TLFinishSavingImageNotification object:nil];
        } else {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

#pragma mark - Capture Video
- (BOOL)isCapturingVideo {
    return self.movieOutput.isRecording;
}

- (NSURL *)tempFileURL {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = NSTemporaryDirectory();
    NSString *filePath = [path stringByAppendingPathComponent:@"tempMovie.mov"];
    return [NSURL fileURLWithPath:filePath];
}

- (void)startCaptureVideo {
    if (!self.isCapturingVideo) {
        AVCaptureConnection *connection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if ([connection isVideoOrientationSupported]) {
            connection.videoOrientation = [self deviceOrientation];
        }
        
        if ([connection isVideoStabilizationSupported]) {
            [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
        }
        
        AVCaptureDevice *device = self.currentInput.device;
        if (device.isSmoothAutoFocusSupported) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                [device setSmoothAutoFocusEnabled:YES];
                [device unlockForConfiguration];
            } else {
                NSLog(@"%@", [error localizedDescription]);
            }
        }
        
        [self.movieOutput startRecordingToOutputFileURL:[self tempFileURL] recordingDelegate:self];
    }
}

- (void)stopCaptureVideo {
    if (self.isCapturingVideo) {
        [self.movieOutput stopRecording];
    }
}

// AVCaptureFileOutputRecordingDelegate Methods
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    
    if (!error) {
        [self writeVideoToAssetsLibrary:outputFileURL];
    } else {
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void)writeVideoToAssetsLibrary:(NSURL *)fileURL {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:fileURL]) {
        
        [library writeVideoAtPathToSavedPhotosAlbum:fileURL completionBlock:^(NSURL *assetURL, NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:TLFinishSavingVideoNotification object:nil];
            }
        }];
    }
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

#pragma mark - Focus & Expose
- (BOOL)canFocusAtPoint {
    AVCaptureDevice *device = self.currentInput.device;
    
    return (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]);
}

- (BOOL)canExposeAtPoint {
    AVCaptureDevice *device = self.currentInput.device;
    
    return (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:AVCaptureExposureModeAutoExpose]);
}

- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = self.currentInput.device;
    
    __weak typeof(self) wSelf = self;
    
    dispatch_async(self.sessionQueue, ^{
        typeof(wSelf) sSelf = wSelf;
        if (!sSelf) {
            return ;
        }
        if ([sSelf canFocusAtPoint]) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                
                // 一定要先设置位置，再设置模式
                // 否则会出现对焦的位置是上一次点击的位置
                // 曝光同理
                [device setFocusPointOfInterest:point];
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                
                [device unlockForConfiguration];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@", [error localizedDescription]);
                });
            }
        }
    });
    
}

- (void)exposeAtPoint:(CGPoint)point {
    AVCaptureDevice *device = self.currentInput.device;
    
    __weak typeof(self) wSelf = self;
    
    dispatch_async(self.sessionQueue, ^{
        typeof(wSelf) sSelf = wSelf;
        if (!sSelf) {
            return ;
        }
        if ([sSelf canExposeAtPoint]) {
            
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                [device setExposurePointOfInterest:point];
                [device setExposureMode:AVCaptureExposureModeAutoExpose];
                
                [device unlockForConfiguration];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@", [error localizedDescription]);
                });
            }
        }
    });
}

#pragma mark - Switch Camera
- (BOOL)isSwitchCameraSupported {
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    return cameraCount > 1;
}

- (void)switchCamera {
    AVCaptureDevice *device = self.currentInput.device;
    __block AVCaptureDevice *newDevice = nil;
    
    __weak typeof(self) wSelf = self;
    
    if ([self isSwitchCameraSupported]) {
        
        dispatch_async(self.sessionQueue, ^{
            typeof(wSelf) sSelf = wSelf;
            if (!sSelf) {
                return ;
            }
            
            if (device.position == AVCaptureDevicePositionFront) {
                newDevice = [sSelf deviceForPosition:AVCaptureDevicePositionBack];
            }
            if (device.position == AVCaptureDevicePositionBack) {
                newDevice = [sSelf deviceForPosition:AVCaptureDevicePositionFront];
            }
            
            AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:nil];
            if (newInput) {
                [sSelf.captureSession beginConfiguration];
                
                [sSelf.captureSession removeInput:sSelf.currentInput];
                if ([sSelf.captureSession canAddInput:newInput]) {
                    [sSelf.captureSession addInput:newInput];
                    sSelf.currentInput = newInput;
                } else {
                    // 如果无法添加新deviceInput，则把原来的deviceInput重新添加
                    [sSelf.captureSession addInput:sSelf.currentInput];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"Cannot switch camera - cannot add new input.");
                    });
                }
                
                [sSelf.captureSession commitConfiguration];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Cannot switch camera - cannot get new input.");
                });
            }
            
        });
        
    } else {
        NSLog(@"Cannot switch camera - no more camera.");
    }
    
}

- (AVCaptureDevice *)deviceForPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    
    return nil;
}

#pragma mark - dealloc
- (void)dealloc {
    [self.motionManager stopDeviceMotionUpdates];
}

@end

















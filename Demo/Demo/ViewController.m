//
//  ViewController.m
//  Demo
//
//  Created by Tony on 2017/3/20.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "ViewController.h"

#import "TLBasicCameraController.h"
#import "TLPreviewView.h"
#import "OverlayView.h"
#import <FileSavingManager.h>

@interface ViewController () <TLPreviewViewDelegate>

@property (weak, nonatomic) IBOutlet OverlayView *overlayView;

@property (strong, nonatomic) TLBasicCameraController *cameraController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.cameraController = [[TLBasicCameraController alloc] init];
    self.cameraController.isSaveVideoToLibrary = YES;
    self.cameraController.isSaveImageToLibrary = YES;
    
    NSError *error = nil;
    if ([self.cameraController setupSession:&error]) {
        
        TLPreviewView *previewView = [[TLPreviewView alloc] initWithFrame:self.view.bounds];
        previewView.session = self.cameraController.captureSession;
        previewView.delegate = self;
        
        previewView.tapToFocusEnable = [self.cameraController canFocusAtPoint];
        previewView.tapToExposeEnable = [self.cameraController canExposeAtPoint];
        
        [self.view insertSubview:previewView belowSubview:self.overlayView];
        
        self.overlayView.switchCamButton.hidden = !self.cameraController.isSwitchCameraSupported;
        
        [self.cameraController startSession];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSavingNotification:) name:TLFinishSavingImageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSavingNotification:) name:TLFinishSavingVideoNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.cameraController stopSession];
}

#pragma mark - Actions
- (IBAction)captureStillImageButtonPressed:(UIButton *)sender {
    if (self.overlayView.segment.selectedSegmentIndex == 0) {
        [self.cameraController captureStillImage];
        [sender setEnabled:NO];
        [self.overlayView.backToViewButton setEnabled:NO];
    } else {
        // 录像
        if (self.cameraController.isCapturingVideo) {
            [self.cameraController stopCaptureVideo];
            [sender setTitle:@"录像" forState:UIControlStateNormal];
            [sender setEnabled:NO];
        } else {
            [sender setTitle:@"停止" forState:UIControlStateNormal];
            [self.overlayView.backToViewButton setEnabled:NO];
            [self.overlayView.switchCamButton setEnabled:NO];
            [self.overlayView.segment setHidden:YES];
            [self.cameraController startCaptureVideo];
        }
    }
}

- (IBAction)switchCameraButtonPressed:(UIButton *)sender {
    [self.cameraController switchCamera];
}

- (IBAction)backToViewButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - TLPreviewViewDelegate Methods
- (void)previewView:(TLPreviewView *)previewView exposeAtPoint:(CGPoint)point {
    [self.cameraController exposeAtPoint:point];
}

- (void)previewView:(TLPreviewView *)previewView focusAtPoint:(CGPoint)point {
    [self.cameraController focusAtPoint:point];
}

#pragma mark - Handle Notifications
- (void)handleSavingNotification:(NSNotification *)notice {
    [self.overlayView.captureButton setEnabled:YES];
    [self.overlayView.backToViewButton setEnabled:YES];
    [self.overlayView.switchCamButton setEnabled:YES];
    [self.overlayView.segment setHidden:NO];
}

#pragma mark -
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

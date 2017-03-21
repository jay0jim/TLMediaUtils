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

@interface ViewController () <TLPreviewViewDelegate>

@property (weak, nonatomic) IBOutlet OverlayView *overlayView;

@property (strong, nonatomic) TLBasicCameraController *cameraController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cameraController = [[TLBasicCameraController alloc] init];
    
    NSError *error = nil;
    if ([self.cameraController setupSession:&error]) {
        
        TLPreviewView *previewView = [[TLPreviewView alloc] initWithFrame:self.view.bounds];
        previewView.session = self.cameraController.captureSession;
        previewView.delegate = self;
        previewView.tapToFocusEnable = [self.cameraController canFocusAtPoint];
        previewView.tapToExposeEnable = [self.cameraController canExposeAtPoint];
        [self.view insertSubview:previewView belowSubview:self.overlayView];
//        [self.view addSubview:previewView];
        
        [self.cameraController startSession];
    }
}

#pragma mark - Actions
- (IBAction)captureStillImageButtonPressed:(UIButton *)sender {
    [self.cameraController captureStillImage];
}

- (IBAction)switchCameraButtonPressed:(UIButton *)sender {
    [self.cameraController switchCamera];
}

#pragma mark - TLPreviewViewDelegate Methods
- (void)previewView:(TLPreviewView *)previewView exposeAtPoint:(CGPoint)point {
    [self.cameraController exposeAtPoint:point];
}

- (void)previewView:(TLPreviewView *)previewView focusAtPoint:(CGPoint)point {
    [self.cameraController focusAtPoint:point];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  JointVideoViewController.m
//  Demo
//
//  Created by Tony on 2017/3/21.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "JointVideoViewController.h"

#import <TLBasicCameraController.h>
#import <TLPreviewView.h>
#import <FileSavingManager.h>

@interface JointVideoViewController ()

@property (strong, nonatomic) TLBasicCameraController *cameraController;

@property (strong, nonatomic) NSMutableArray *videoURLArray;

@end

@implementation JointVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.cameraController = [[TLBasicCameraController alloc] init];
    NSError *error;
    if ([self.cameraController setupSession:&error]) {
        TLPreviewView *previewView = [[TLPreviewView alloc] initWithFrame:self.view.bounds];
        previewView.session = self.cameraController.captureSession;
        
        [self.view insertSubview:previewView atIndex:0];
        
        [self.cameraController startSession];
    } else {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    self.videoURLArray = [NSMutableArray array];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.cameraController stopSession];
}

#pragma mark - Actions
- (IBAction)backToViewButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (IBAction)captureVideoButtonPressed:(UIButton *)sender {
    
    if (!self.cameraController.isCapturingVideo) {
        NSString *fileName = [NSString stringWithFormat:@"%ld.mov", self.videoURLArray.count];
        NSURL *fileURL = [FileSavingManager urlWithFileName:fileName];
        [self.videoURLArray addObject:fileURL];
        self.cameraController.outputVideoURL = fileURL;
        
        [self.cameraController startCaptureVideo];
        
        [sender setTitle:@"停止" forState:UIControlStateNormal];
    } else {
        [self.cameraController stopCaptureVideo];
        
        [sender setTitle:@"录像" forState:UIControlStateNormal];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end















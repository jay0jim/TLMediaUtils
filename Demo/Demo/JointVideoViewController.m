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

@interface JointVideoViewController ()

@property (strong, nonatomic) TLBasicCameraController *cameraController;

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
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.cameraController stopSession];
}

#pragma mark - Actions
- (IBAction)backToViewButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end















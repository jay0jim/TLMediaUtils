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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TLBasicCameraController *cameraController = [[TLBasicCameraController alloc] init];
    
    NSError *error = nil;
    if ([cameraController setupSession:&error]) {
        
        TLPreviewView *previewView = [[TLPreviewView alloc] initWithFrame:self.view.bounds];
        previewView.session = cameraController.captureSession;
        [self.view addSubview:previewView];
        
        [cameraController startSession];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

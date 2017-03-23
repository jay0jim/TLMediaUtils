//
//  FilterViewController.m
//  Demo
//
//  Created by Tony on 2017/3/23.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "FilterViewController.h"

#import <ImageFilter.h>

#define screenWidth  [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height

@interface FilterViewController ()

@property (strong, nonatomic) UIImageView *displayView;

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *testPicPath = [[NSBundle mainBundle] pathForResource:@"testPic" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:testPicPath];
    
    ImageFilter *filter = [[ImageFilter alloc] init];
    CGImageRef filteredImageRef = [filter setFilter:nil OnImage:image.CGImage];
    UIImage *displayImage = [UIImage imageWithCGImage:filteredImageRef];
    
    self.displayView = [[UIImageView alloc] initWithImage:displayImage];
    self.displayView.frame = CGRectMake(0, 30, screenWidth, screenWidth * 4/3);
    self.displayView.center = self.view.center;
    [self.view addSubview:self.displayView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

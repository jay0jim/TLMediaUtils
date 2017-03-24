//
//  FilterViewController.m
//  Demo
//
//  Created by Tony on 2017/3/23.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "FilterViewController.h"

#import <FilterManager.h>

#define screenWidth  [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height

@interface FilterViewController ()

@property (strong, nonatomic) UIImageView *displayView;
@property (strong, nonatomic) UIImageView *displayView2;

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *testPicPath = [[NSBundle mainBundle] pathForResource:@"testPic" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:testPicPath];
    
    FilterManager *filter = [[FilterManager alloc] init];
    CGImageRef filteredImageRef = [filter setFilter:@"CISepiaTone" OnImage:image.CGImage];
    UIImage *displayImage = [UIImage imageWithCGImage:filteredImageRef];
    
    self.displayView = [[UIImageView alloc] initWithImage:displayImage];
    self.displayView.frame = CGRectMake(0, self.view.center.y - 100, screenWidth / 2, screenWidth / 2 * 4/3);
    [self.view addSubview:self.displayView];
    
    UIImage *image2 = [UIImage imageWithContentsOfFile:testPicPath];

    CGImageRef filteredImageRef2 = [filter setFilter:@"CIGaussianBlur" OnImage:image2.CGImage];
    UIImage *displayImage2 = [UIImage imageWithCGImage:filteredImageRef2];
    
    self.displayView2 = [[UIImageView alloc] initWithImage:displayImage2];
    self.displayView2.frame = CGRectMake(screenWidth/2, self.view.center.y, screenWidth/2, screenWidth/2 * 4/3);
    [self.view addSubview:self.displayView2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

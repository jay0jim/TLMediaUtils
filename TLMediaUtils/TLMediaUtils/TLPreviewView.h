//
//  TLPreviewView.h
//  TLMediaUtils
//
//  Created by Tony on 2017/3/20.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

@interface TLPreviewView : UIView

@property (strong, nonatomic) AVCaptureSession *session;

@end

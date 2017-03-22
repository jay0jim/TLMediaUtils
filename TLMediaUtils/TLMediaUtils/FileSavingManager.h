//
//  FileSavingManager.h
//  TLMediaUtils
//
//  Created by Tony on 2017/3/22.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

extern NSString *TLFinishSavingImageNotification;
extern NSString *TLFinishSavingVideoNotification;

@interface FileSavingManager : NSObject

- (void)writeImageToAssetsLibrary:(UIImage *)image;
- (void)writeVideoToAssetsLibrary:(NSURL *)fileURL;

- (void)writeJPEGImage:(UIImage *)image ToURL:(NSURL *)fileURL;
- (void)writeVideoFromURL:(NSURL *)fromURL ToURL:(NSURL *)fileURL;

@end

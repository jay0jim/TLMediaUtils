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
extern NSString *TLSavingErrorNotification;

@interface FileSavingManager : NSObject

/**
 * 在Document目录后接文件名

 @param fileName 文件名
 @return 包含文件名的fileURL
 */
+ (NSURL *)urlWithFileName:(NSString *)fileName;

- (void)writeImageToAssetsLibrary:(UIImage *)image;
- (void)writeVideoToAssetsLibrary:(NSURL *)fileURL;

- (void)writeJPEGImage:(UIImage *)image ToURL:(NSURL *)fileURL;
- (void)writeVideoFromURL:(NSURL *)fromURL ToURL:(NSURL *)fileURL;

@end

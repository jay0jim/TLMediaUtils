//
//  FileSavingManager.m
//  TLMediaUtils
//
//  Created by Tony on 2017/3/22.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "FileSavingManager.h"

NSString *TLFinishSavingImageNotification = @"ImageSavingDone";
NSString *TLFinishSavingVideoNotification = @"VideoSavingDone";
NSString *TLSavingErrorNotification = @"SavingError";

@interface FileSavingManager ()

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;

@property (strong, nonatomic) dispatch_queue_t savingQueue;

@end

@implementation FileSavingManager

- (instancetype)init {
    if (self = [super init]) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        self.savingQueue = dispatch_queue_create("savingQueue", NULL);
    }
    return self;
}

+ (NSURL *)urlWithFileName:(NSString *)fileName {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL;
}

#pragma mark - Write to AssetsLibrary
- (void)writeImageToAssetsLibrary:(UIImage *)image {
    
    [self.assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:(NSUInteger)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error) {
            
        } else {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

- (void)writeVideoToAssetsLibrary:(NSURL *)fileURL {
    
    if ([self.assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:fileURL]) {
        
        [self.assetsLibrary writeVideoAtPathToSavedPhotosAlbum:fileURL completionBlock:^(NSURL *assetURL, NSError *error) {
            if (!error) {
                
            }
        }];
    }
}

#pragma mark - Write to URL
- (void)writeJPEGImage:(UIImage *)image ToURL:(NSURL *)fileURL {
    if (fileURL) {
        dispatch_async(self.savingQueue, ^{
            NSData *imageData = UIImageJPEGRepresentation(image, 1);
            
            if (![imageData writeToURL:fileURL atomically:YES]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Cannot save image to URL.");
                });
                [[NSNotificationCenter defaultCenter] postNotificationName:TLSavingErrorNotification object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:TLFinishSavingImageNotification object:nil];
            }
        });
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:TLSavingErrorNotification object:nil];
    }
}

- (void)writeVideoFromURL:(NSURL *)fromURL ToURL:(NSURL *)fileURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *fromPath = [fromURL path];
    NSString *toPath = [fileURL path];
    
    if (!fromURL || !fileURL) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TLSavingErrorNotification object:nil];
        return;
    }
    
    [fileManager removeItemAtURL:fileURL error:nil];
    
    if ([fileManager fileExistsAtPath:fromPath]) {
        dispatch_async(self.savingQueue, ^{
            NSError *error;
            if ([fileManager copyItemAtURL:fromURL toURL:fileURL error:&error]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:TLFinishSavingVideoNotification object:nil];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@", [error localizedDescription]);
                });
                [[NSNotificationCenter defaultCenter] postNotificationName:TLSavingErrorNotification object:nil];
            }
        });
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:TLSavingErrorNotification object:nil];
    }
}

@end
















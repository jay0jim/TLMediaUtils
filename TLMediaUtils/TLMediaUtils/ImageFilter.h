//
//  ImageFilter.h
//  TLMediaUtils
//
//  Created by Tony on 2017/3/23.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

typedef enum : NSUInteger {
    TLFileterTypeNone = 0,
} TLFilterType;

@interface ImageFilter : NSObject

- (CGImageRef)setFilter:(NSString *)filterName OnImage:(CGImageRef)imageRef;

@end

//
//  FilterManager.h
//  TLMediaUtils
//
//  Created by Tony on 2017/3/24.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@interface FilterManager : NSObject

- (CGImageRef)setFilter:(NSString *)filterName OnImage:(CGImageRef)imageRef;

@end

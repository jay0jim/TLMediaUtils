//
//  FilterManager.m
//  TLMediaUtils
//
//  Created by Tony on 2017/3/24.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "FilterManager.h"

@interface FilterManager ()

@property (strong, nonatomic) CIContext *context;
@property (strong, nonatomic) EAGLContext *glContext;

@end

@implementation FilterManager

- (instancetype)init {
    if (self = [super init]) {
        
        self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (self.glContext) {
            self.context = [CIContext contextWithEAGLContext:self.glContext];
        } else {
            NSLog(@"Failed to create OpenGLES context.");
        }
    }
    return self;
}

- (CGImageRef)setFilter:(NSString *)filterName OnImage:(CGImageRef)imageRef {
    
    CIFilter *filter = [CIFilter filterWithName:filterName];
    
    CIImage *image = [CIImage imageWithCGImage:imageRef];
    
    [filter setValue:image forKey:kCIInputImageKey];
    CIImage *outputImage = filter.outputImage;
    
    CGImageRef result = [self.context createCGImage:outputImage fromRect:outputImage.extent];
    return result;
}

@end

//
//  ImageFilter.m
//  TLMediaUtils
//
//  Created by Tony on 2017/3/23.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "ImageFilter.h"


@interface ImageFilter ()

@property (strong, nonatomic) CIContext *context;
@property (strong, nonatomic) EAGLContext *glContext;

@end

@implementation ImageFilter

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
    
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
    
    CIImage *image = [CIImage imageWithCGImage:imageRef];
    
    [filter setValue:image forKey:kCIInputImageKey];
    CIImage *outputImage = filter.outputImage;
    
    CGImageRef result = [self.context createCGImage:outputImage fromRect:outputImage.extent];
    return result;
}

@end

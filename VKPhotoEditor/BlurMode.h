//
//  BlurMode.h
//  VKPhotoEditor
//
//  Created by asya on 10/4/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageFilter.h"


@interface BlurMode : NSObject

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong, readonly) UIImage *iconImage;
@property (nonatomic, strong, readonly) GPUImageOutput <GPUImageInput> *filter;
@property (nonatomic, assign, readonly) BOOL hasFilter;

BlurMode *MakeBlurMode(NSString *filterName, NSString *imageName, NSString *iconImageName);

@end

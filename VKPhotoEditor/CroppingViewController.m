//
//  CroppingViewController.m
//  VKPhotoEditor
//
//  Created by asya on 9/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "CroppingViewController.h"
#import "UIImage+Resize.h"
#import "ZoomingView.h"
#import "FlexibleButton.h"
#import "PhotoEditController.h"
#import "Filters.h"
#import "GPUImageFilter.h"
#import "BlurFilterParams.h"

@interface CroppingViewController () {
    IBOutlet UIView *captureView;
    IBOutlet UIView *zoomingPlaceholder;
    IBOutlet FlexibleButton *cancelBtn;
    IBOutlet FlexibleButton *chooseBtn;
    
    ZoomingView *zoomingView;
    UIImage *image;
    NSInteger filterIndex;
}

@end

@implementation CroppingViewController 

@synthesize delegate;

- (id)initWithImage:(UIImage *)_image filterIndex:(NSInteger)_filterIndex userInfo:(NSDictionary *)userInfo
{
    self = [super init];
    if (self) {
        image = _image;
        filterIndex = _filterIndex;
        
        GPUImageOutput<GPUImageInput> *blurFilter = [BlurFilterParams filterWithParams:userInfo];
        if (blurFilter) {
            image = [blurFilter imageByFilteringImage:_image];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *filters = Filters.filters;
    GPUImageOutput<GPUImageInput> *filter = [Filters GPUFilterWithName:[[filters objectAtIndex:filterIndex] name]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[filter imageByFilteringImage:image]];
    
    zoomingView = [[ZoomingView alloc] initWithContentView:imageView frame:captureView.frame];
    zoomingView.shouldClip = NO;
    zoomingView.contentMode = image.size.width > image.size.height ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;
    [zoomingPlaceholder addSubview:zoomingView];
    
    cancelBtn.bgImagecaps = CGSizeMake(20, 20);
    chooseBtn.bgImagecaps = CGSizeMake(20, 20);
    
    captureView.layer.borderWidth = 2;
    captureView.layer.borderColor = [[UIColor whiteColor] CGColor];
}


#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [delegate croppingViewControllerDidCancel:self];
}

- (IBAction)choose:(id)sender
{
    CGFloat x = zoomingView.contentOffset.x/zoomingView.zoomScale;
    CGFloat y = (zoomingView.contentOffset.y)/zoomingView.zoomScale;
    CGFloat width = CGRectGetWidth(captureView.frame)/zoomingView.zoomScale;
    CGFloat height = CGRectGetHeight(captureView.frame)/zoomingView.zoomScale;
    UIImage *cropImage = [image croppedImage:CGRectMake(x, y, width, height)];

    [delegate croppingViewController:self didFinishWithImage:cropImage filterIndex:filterIndex];
}

@end

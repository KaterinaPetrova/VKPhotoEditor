//
//  PhotoEditController.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "PhotoEditController.h"
#import "FlexibleButton.h"
#import "Filters.h"
#import "UIColor+VKPhotoEditor.h"
#import "CaptionView.h"
#import "UIView+Helpers.h"
#import "ImageFilter.h"
#import "GPUImagePicture.h"
#import "SPUserResizableView.h"
#import "UIImage+GPUOrientation.h"
#import "DemotivatorCaptionView.h"
#import "CaptionTemplateProtocol.h"
#import "ActivityView.h"
#import "ArrowView.h"
#import "FiltersManager.h"
#import "BlurView.h"
#import "CaptionTextView.h"
#import "UIImage+Blend.h"

#define MAX_FONT_SIZE 100

@interface PhotoEditController () <ThumbnailsViewDelegate, ThumbnailsViewDataSource, BlurViewDelegate, CaptionTextViewDelegate>
@end

@implementation PhotoEditController {
    NSArray *filters;
    CGPoint oldContentOffset;
    UIImage *image;
    NSInteger filterIndex;
    GPUImagePicture *sourcePicture;
    UIView<CaptionTemplateProtocol> *captionViewTemplate;
    NSArray *captionTemplates;
    NSInteger captionTemplateIndex;
    ActivityView *activityView;
    ArrowView *arrowView;
    GPUImageOutput<GPUImageInput> *blurFilter;
    FiltersManager *manager;
    BlurView *blurView;
    CaptionTextView *captionView;
    BOOL replyToFeed;
}

@synthesize saveButton;
@synthesize retakeButton;
@synthesize cancelButton;
@synthesize filterView;
@synthesize contentView;
@synthesize scrollView;
@synthesize imageView;
@synthesize topView;
@synthesize delegate;
@synthesize captionOverlayView;
@synthesize leftRecognizer;
@synthesize rightRecognizer;
@synthesize blurButton;
@synthesize isPhoto;
@synthesize isAvatar;
@synthesize avatarTagLabel;
@synthesize publishReplyButton;
@synthesize replyToPhoto;

- (id)initWithImage:(UIImage *)_image filterIndex:(NSInteger)_filterIndex blurFilter:(id)_blurFilter
{
    self = [super init];
    if (self) {
        image = _image;
        filterIndex = _filterIndex;
        blurFilter = _blurFilter;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor defaultBgColor];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
    
    [contentView resizeTo:[[UIScreen mainScreen] bounds].size];
    [scrollView addSubview:contentView];
    scrollView.contentSize = contentView.frame.size;
    
    avatarTagLabel.hidden = !isAvatar;
    avatarTagLabel.font = [UIFont fontWithName:@"Lobster" size:28];
    avatarTagLabel.textColor = [UIColor colorWithRed:149.0/255 green:200.0/255 blue:255.0/255 alpha:1];
    
    saveButton.bgImagecaps = CGSizeMake(23, 0);
    retakeButton.bgImagecaps = CGSizeMake(23, 20);
    cancelButton.bgImagecaps = CGSizeMake(23, 20);
    publishReplyButton.bgImagecaps = CGSizeMake(23, 20);
    [retakeButton setTitle:isPhoto ? @"Retake" : @"Select" forState:UIControlStateNormal];
    
    sourcePicture = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageOutput<GPUImageInput> *basicFilter = [GPUImageEmptyFilter new];
    [basicFilter addTarget:imageView];
    [basicFilter setInputRotation:image.rotationMode atIndex:0];
    [sourcePicture addTarget:basicFilter];
    
    filters = Filters.filters;
    filterView.margin = 7;
    filterView.thumbConrnerRadius = 7.0;
    
    [filterView resizeTo:CGSizeMake(filterView.frame.size.width, topView.frame.origin.y + 4)];
    [filterView reloadData];
    filterView.displayedItemIndex = filterIndex;
    
    captionTemplates = Filters.captionViewTemplates;
    captionTemplateIndex = 0;
    [self setCaptionViewTemplate:[captionTemplates objectAtIndex:captionTemplateIndex]];
    
    captionView = [CaptionTextView loadFromNIB];
    captionView.center = CGPointMake(self.view.center.x, 290);
    captionView.delegate = self;
    captionView.captionButtonTitle = isAvatar ? @"Your name" : @"Add caption";
    
    [topView addSubview:captionView];
    
    activityView = [ActivityView loadFromNIB];
    [self.view addSubview:activityView];
    
    arrowView = [ArrowView loadFromNIB];
    [topView addSubview:arrowView];
    [arrowView moveTo:CGPointMake(0, 200)];
    
    filterView.highlight = YES;
    
    blurView = [[BlurView alloc] initWithCenter:CGPointMake(270, 60) margin:CGRectGetMaxY(blurButton.frame)];
    blurView.delegate = self;
    [blurView setModeWithFilter:blurFilter];
    [topView addSubview:blurView];
    [topView addGestureRecognizer:blurView.pinch];
    
    manager = FiltersManagerMake(basicFilter, sourcePicture, imageView);
    
    [self setFilterWithIndex:filterIndex];
    [self setBlurFilterWithFilter:blurFilter];
    
    publishReplyButton.hidden = !replyToPhoto;
}

- (void)setFilterWithIndex:(NSInteger)index
{ 
    [manager setFilterWithIndex:index prepare:nil];
    [sourcePicture processImage];
}

- (void)setBlurFilterWithFilter:(id)filter
{
    [manager setBlurFilterWithFilter:filter prepare:nil];
    [sourcePicture processImage];
}

- (void)resizeScrollView:(BOOL)show notification:(NSNotification *)n
{
    NSDictionary* userInfo = [n userInfo];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [scrollView.superview convertRect:keyboardFrame fromView:scrollView.window];
    CGFloat duration;
    CGRect viewFrame = scrollView.superview.bounds;
    if (show) {
        duration = 0.30;
        viewFrame.size.height = keyboardFrame.origin.y;
    } else {
        duration = 0.45;
        viewFrame = scrollView.superview.bounds;
    }
    [UIView animateWithDuration:duration animations:^{
        scrollView.frame = viewFrame;
    }];
    scrollView.contentOffset = show ? CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height) : oldContentOffset;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    oldContentOffset = scrollView.contentOffset;
    [self resizeScrollView:YES notification:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self resizeScrollView:NO notification:notification];
}

- (UIImage *)imageByApplingFilters
{
    if (manager.blurFilter) {
        return [self imageByApplingFilter:manager.blurFilter];
    } else {
        return [self imageByApplingFilter:manager.basicFilter];
    }
}

- (UIImage *)imageByApplingFilter:(GPUImageOutput<GPUImageInput> *)filter
{
    UIImage *filteredImage = nil;
    
    if (filter.targets.count) {
        filteredImage = [filter.targets.lastObject imageFromCurrentlyProcessedOutput];
    } else {
        filteredImage = [filter imageFromCurrentlyProcessedOutput];
    }
    
    return filteredImage;
}

#pragma mark actions

- (void)setCaptionViewTemplate:(UIView<CaptionTemplateProtocol>*)_captionViewTemplate
{
    [captionViewTemplate removeFromSuperview];
    [captionOverlayView addSubview:_captionViewTemplate];
    captionViewTemplate = _captionViewTemplate;
}

- (IBAction)nextCaptionTemplate
{
    captionTemplateIndex =  ( captionTemplateIndex == captionTemplates.count - 1 ? 0 : captionTemplateIndex + 1 );
    [self setCaptionViewTemplate:[captionTemplates objectAtIndex:captionTemplateIndex]];
}

- (IBAction)prevCaptionTemplate
{
     captionTemplateIndex =  ( !captionTemplateIndex ?  captionTemplates.count - 1 : captionTemplateIndex - 1 );
    [self setCaptionViewTemplate:[captionTemplates objectAtIndex:captionTemplateIndex]];
}

- (IBAction)save
{
    [captionView resignFirstResponder];
    [activityView showSelf:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        CGFloat side = fmaxf(image.size.width, image.size.height);
        [captionViewTemplate removeFromSuperview];
        [captionViewTemplate resizeTo:CGSizeMake(side, side)];
        UIImage *output = [self imageByApplingFilters];
  
        output = [output squareImageByBlendingWithImage:captionViewTemplate.templateImage];
        
        NSString *caption = captionView.caption;
        if (isAvatar) {
            caption = [NSString stringWithFormat:@"#me %@", caption];
        }
        
        [activityView showSelf:NO];
        [delegate photoEditController:self didFinishWithImage:ImageToUploadMake(output, caption, replyToPhoto.account.login, replyToPhoto.photoId, [NSNumber numberWithBool:replyToFeed])];
    });
}

- (IBAction)cancel
{
    [captionView resignFirstResponder];
    [delegate photoEditControllerDidCancel:self];
}

- (IBAction)retake
{
    [captionView resignFirstResponder];
    
    if (isPhoto) {
        [delegate photoEditControllerDidRetake:self];
    } else {
        [delegate photoEditControllerDidSelect:self];
    }
}

- (IBAction)selectBlur
{
    [blurView reloadData];
    [blurView show:!blurView.isShown];
}

- (IBAction)publishReply
{
    publishReplyButton.selected = !publishReplyButton.selected;
    replyToFeed = publishReplyButton.selected;
    
    CGSize size = publishReplyButton.frame.size;
    size.width = replyToFeed ? 250 : 43;
    
    [UIView animateWithDuration:0.5 animations:^(){
        [publishReplyButton resizeTo:size];
    } completion:^(BOOL finish) {
        [publishReplyButton setTitle:replyToFeed ? @"All your folowers will see this reply" : @"" forState:UIControlStateNormal];
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"Erorr saving photo: %@",error);
    } else {
        [delegate photoEditControllerDidCancel:self];
    }
}

#pragma mark ThumbnailView datasourse

- (NSUInteger)numberOfItemsInThumbnailsView:(ThumbnailsView*)view
{
    return filters.count;
}

- (UIView*)thumbnailsView:(ThumbnailsView*)view viewForItemWithIndex:(NSUInteger)index
{
    ImageFilter *imageFilter = [filters objectAtIndex:index];
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageFilter.previewPath]];
}

- (CGFloat)thumbnailsView:(ThumbnailsView*)view thumbnailWidthForHeight:(CGFloat)height
{
    return height;
}

#pragma mark ThumbnailView delegate

- (void)thumbnailsView:(ThumbnailsView*)view didScrollToItemWithIndex:(NSUInteger)index
{
    
}
- (void)thumbnailsView:(ThumbnailsView *)view didTapOnItemWithIndex:(NSUInteger)index
{
    [self setFilterWithIndex:index];
}

#pragma mark - BlurViewDelegate

- (void)blurView:(BlurView *)view didFinishWithBlurMode:(BlurMode *)mode blurFilter:(id)filter
{
    [blurButton setImage:mode.iconImage forState:UIControlStateNormal];
    [self setBlurFilterWithFilter:filter];
}

- (void)blurView:(BlurView *)view didChangeBlurScale:(CGFloat)scale
{
    [manager setBlurFilterScale:scale];
    [sourcePicture processImage];
}

- (void)blurViewDidBeginBlurScaleEditing:(BlurView *)view
{
    [manager beginBlurScaleEditing];
    [sourcePicture processImage];
}

- (void)blurViewDidFinishBlurScaleEditing:(BlurView *)view
{
    [manager finishBlurScaleEditing];
    [sourcePicture processImage];
}

#pragma mark - CaptionTextViewDelegate

- (void)captionTextViewDidStartEditing:(CaptionTextView *)view
{
}

- (void)captionTextViewDidFinishEditing:(CaptionTextView *)view
{
    NSLog(@"text: %@", captionView.caption);
}

@end
